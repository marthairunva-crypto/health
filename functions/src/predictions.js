/**
 * Prediction functions using Groq AI
 */

const {HttpsError} = require('firebase-functions/v2/https');
const admin = require('firebase-admin');

/**
 * Generate risk prediction for a visit using Groq AI
 * @param {Object} data - { patientAge, sex, symptoms, vitalSigns, diagnosis }
 * @param {Object} context - Auth context
 */
async function predictRisk(data, context) {
  // Check authentication
  if (!context.auth) {
    throw new HttpsError('unauthenticated', 'User must be authenticated');
  }

  const {patientAge, sex, symptoms, vitalSigns, diagnosis} = data;

  if (!patientAge || !sex || !symptoms) {
    throw new HttpsError('invalid-argument', 'Patient data is required');
  }

  try {
    // Get Groq API key
    const groqApiKey = process.env.GROQ_API_KEY || 
                       (process.env.FUNCTIONS_EMULATOR === 'true' ? 
                        process.env.GROQ_API_KEY : 
                        context.instanceIdToken);

    if (!groqApiKey) {
      throw new HttpsError('failed-precondition', 'Groq API key not configured');
    }

    // Build prompt for Groq
    const prompt = buildMedicalPrompt(patientAge, sex, symptoms, vitalSigns, diagnosis);

    // Call Groq API
    const groqResponse = await fetch('https://api.groq.com/openai/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${groqApiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'llama-3.3-70b-versatile',
        messages: [
          {
            role: 'system',
            content: 'You are a medical AI assistant specializing in health risk assessment for rural Uganda healthcare. Provide risk assessments and recommendations based on patient symptoms and vital signs. Always respond in JSON format.',
          },
          {
            role: 'user',
            content: prompt,
          },
        ],
        temperature: 0.3,
        max_tokens: 1000,
        response_format: {type: 'json_object'},
      }),
    });

    if (!groqResponse.ok) {
      const errorText = await groqResponse.text();
      console.error('Groq API error:', errorText);
      throw new HttpsError('internal', `Groq API error: ${groqResponse.status}`);
    }

    const groqData = await groqResponse.json();
    const aiResponse = JSON.parse(groqData.choices[0].message.content);

    // Return structured prediction
    return {
      riskLevel: aiResponse.riskLevel || 'medium',
      riskScore: aiResponse.riskScore || 0.5,
      riskFactors: aiResponse.riskFactors || [],
      recommendations: aiResponse.recommendations || [],
      urgency: aiResponse.urgency || 'routine',
      reasoning: aiResponse.reasoning || '',
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    };
  } catch (error) {
    console.error('Error in predictRisk:', error);
    
    // Fallback to basic calculation if AI fails
    const fallbackRisk = calculateBasicRisk(symptoms, vitalSigns);
    return {
      riskLevel: fallbackRisk.level,
      riskScore: fallbackRisk.score,
      riskFactors: fallbackRisk.factors,
      recommendations: fallbackRisk.recommendations,
      urgency: 'routine',
      reasoning: 'AI prediction unavailable, using basic risk calculation',
      fallbackUsed: true,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    };
  }
}

/**
 * Build medical assessment prompt for Groq
 */
function buildMedicalPrompt(age, sex, symptoms, vitalSigns, diagnosis) {
  const symptomsText = Array.isArray(symptoms) ? symptoms.join(', ') : 'None reported';
  const vitalsText = vitalSigns ? JSON.stringify(vitalSigns) : 'Not recorded';

  return `Assess the health risk for this patient presenting at a rural health center in Uganda:

Patient Profile:
- Age: ${age} years
- Sex: ${sex}
- Presenting Symptoms: ${symptomsText}
- Vital Signs: ${vitalsText}
- Provisional Diagnosis: ${diagnosis || 'Not yet determined'}

Please provide a comprehensive risk assessment in the following JSON format:
{
  "riskLevel": "low|medium|high|critical",
  "riskScore": 0.0-1.0,
  "riskFactors": ["specific risk factors identified"],
  "recommendations": ["actionable clinical recommendations"],
  "urgency": "routine|urgent|emergency",
  "reasoning": "brief explanation of the assessment"
}

Consider:
1. Severity of symptoms
2. Vital sign abnormalities
3. Age-related risk factors
4. Common diseases in rural Uganda (malaria, typhoid, pneumonia, etc.)
5. Resource constraints of rural health centers
6. Need for referral to higher-level facilities`;
}

/**
 * Fallback basic risk calculation
 */
function calculateBasicRisk(symptoms, vitalSigns) {
  let riskPoints = 0;
  const factors = [];
  const recommendations = [];

  // Analyze symptoms
  const criticalSymptoms = ['Difficulty breathing', 'Chest pain', 'Severe bleeding', 'Loss of consciousness'];
  const highRiskSymptoms = ['High fever', 'Persistent vomiting', 'Severe headache', 'Confusion'];

  symptoms.forEach((symptom) => {
    if (criticalSymptoms.some((cs) => symptom.toLowerCase().includes(cs.toLowerCase()))) {
      riskPoints += 3;
      factors.push(`Critical symptom: ${symptom}`);
    } else if (highRiskSymptoms.some((hs) => symptom.toLowerCase().includes(hs.toLowerCase()))) {
      riskPoints += 2;
      factors.push(`High-risk symptom: ${symptom}`);
    } else {
      riskPoints += 1;
    }
  });

  // Analyze vital signs
  if (vitalSigns) {
    const temp = parseFloat(vitalSigns.temperature);
    if (temp > 39) {
      riskPoints += 2;
      factors.push('Very high fever');
    } else if (temp > 38) {
      riskPoints += 1;
      factors.push('Elevated temperature');
    }
  }

  // Determine risk level
  const score = Math.min(riskPoints / 15, 1.0);
  let level;
  if (score >= 0.7) {
    level = 'critical';
    recommendations.push('Immediate medical attention required');
    recommendations.push('Consider referral to district hospital');
  } else if (score >= 0.5) {
    level = 'high';
    recommendations.push('Close monitoring required');
    recommendations.push('Frequent follow-up needed');
  } else if (score >= 0.3) {
    level = 'medium';
    recommendations.push('Standard treatment protocol');
    recommendations.push('Schedule follow-up visit');
  } else {
    level = 'low';
    recommendations.push('Routine care');
    recommendations.push('Home care with monitoring');
  }

  return {level, score, factors, recommendations};
}

module.exports = {
  predictRisk,
};
