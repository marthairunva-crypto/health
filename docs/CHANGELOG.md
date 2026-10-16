# Changelog

All notable changes to the Nsiika Health Centre IV Prediction App will be documented here.

## [Unreleased]

### Added
- Initial project structure with feature-first architecture
- Core data models with Freezed (Patient, Visit, Prediction, User, FacilityDaily)
- Firebase Functions structure with JavaScript (Node 20)
- Firestore security rules with role-based access control
- Core constants and enums synchronized across Dart and JavaScript
- Firebase configuration and emulator setup
- Documentation: ASSUMPTIONS.md, DEPLOY.md, GROQ_MODELS.md
- Project structure and next steps guides
- Groq API key configured for local development (.env.local)
- Environment variable loading for emulators (dotenv)

### Changed
- Replaced TypeScript with JavaScript for Cloud Functions
- Replaced TensorFlow with rule-based baseline + Groq LLM approach
- Verified and updated Groq model configuration (llama-3.3-70b-versatile)

### Todo
- [ ] Implement remaining Cloud Functions (predictRisk, triggers, exports)
- [ ] Create baseline risk calculation model
- [ ] Implement Groq API integration with de-identification
- [ ] Build Flutter UI screens and navigation
- [ ] Add localization support (English + Runyankole)
- [ ] Create synthetic data generation tool
- [ ] Write tests (unit, widget, rules, integration)
- [ ] Set up CI/CD pipeline
- [ ] Create validation/evaluation scripts

## Version Format

We use [Semantic Versioning](https://semver.org/):
- MAJOR version for incompatible API changes
- MINOR version for backwards-compatible functionality additions
- PATCH version for backwards-compatible bug fixes

## Categories

- **Added**: New features
- **Changed**: Changes in existing functionality
- **Deprecated**: Soon-to-be removed features
- **Removed**: Removed features
- **Fixed**: Bug fixes
- **Security**: Vulnerability fixes
