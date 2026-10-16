# Clinical and Technical Assumptions

This document tracks assumptions made during development that should be validated with Nsiika Health Centre IV clinicians.

## Clinical Assumptions

### Risk Factor Weights (Baseline Model)
- **Age extremes**: Children <5 years and adults >65 years have 1.5x base risk
- **Vital sign thresholds**:
  - SpO2 <92%: Moderate hypoxia marker
  - Temperature ≥38.5°C: Significant fever
  - Respiratory rate >30/min (adults) or >50/min (infants): Respiratory distress
  - Systolic BP <90mmHg: Hypotension concern
- **Pregnancy**: 1.3x base risk multiplier
- **Chronic conditions**: Each adds weight (HIV: 1.2, Hypertension: 1.1, Diabetes: 1.15, etc.)

### Health System Factor Weights
- **Wait time**: >120 minutes adds moderate risk
- **Referral delay**: >4 hours significantly increases risk
- **Stock-outs**: Each critical medicine unavailable adds weight
- **Night/weekend shift**: 1.2x multiplier (fewer staff, limited lab)
- **Low staffing**: <2 clinicians on duty increases risk

### Outcome Definitions
- **Complication**: New clinical problem arising during or shortly after visit
- **Delayed treatment**: >2 hour delay from triage to intervention for urgent cases
- **Readmission within 30 days**: Return visit with same or related complaint
- **Clinical deterioration**: Worsening vital signs or condition within 24 hours
- **Preventable death risk**: Life-threatening situation with modifiable system factors

## Technical Assumptions

### Data Availability
- Clinicians will record vital signs for most patients
- Facility daily data (staffing, stock-outs) will be entered each shift
- Internet connectivity available at least once daily for sync
- 30-day outcome follow-up is feasible for validation

### User Behavior
- Health workers prefer mobile over desktop
- English is acceptable for UI (Runyankole labels as enhancement)
- 3-step visit form is not too long
- Clinicians will provide feedback on predictions

### System Constraints
- Firebase free tier sufficient for development and initial deployment
- Groq API latency acceptable (<5 seconds typical)
- Offline data entry without immediate prediction is acceptable
- APK side-loading is acceptable (no Google Play requirement)

## Items Requiring Validation

1. **Clinical thresholds**: Review all vital sign thresholds with facility clinicians
2. **Risk factor weights**: Validate baseline model weights against local experience
3. **Outcome definitions**: Confirm how facility tracks adverse outcomes
4. **Medicine list**: Get actual stock list for medicine dropdowns
5. **Presenting complaint terms**: Common local terminology
6. **User workflow**: Test 3-step visit wizard with actual users
7. **Data collection feasibility**: Confirm 30-day follow-up is realistic

## Notes
- All clinical assumptions marked with `// ASSUMPTION:` in code
- Baseline model should be reviewed before deployment
- LLM predictions are experimental and require validation against real outcomes
