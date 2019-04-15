library discrimapp;

// Dart
export 'dart:async';

// Flutter
export 'package:flutter/material.dart';
export 'package:flutter/services.dart' show PlatformException;

// Third party
export 'package:audioplayers/audio_cache.dart';
export 'package:cloud_firestore/cloud_firestore.dart';
export 'package:firebase_auth/firebase_auth.dart';
export 'package:queries/collections.dart';

// Controls
export 'package:visual_discrimination_app/Controls/OneStimuliPreTeachingField.dart';
export 'package:visual_discrimination_app/Controls/TwoStimuliPreTeachingField.dart';
export 'package:visual_discrimination_app/Controls/TwoStimuliTrainingField.dart';

// Dialogs
export 'package:visual_discrimination_app/Dialogs/ErrorDialog.dart';
export 'package:visual_discrimination_app/Dialogs/FeedbackDialog.dart';
export 'package:visual_discrimination_app/Dialogs/StatusDialog.dart';

// Helpers
export 'package:visual_discrimination_app/Auth/Auth.dart';
export 'package:visual_discrimination_app/Auth/AuthProvider.dart';
export 'package:visual_discrimination_app/Utilities/Scoring.dart';

// Models
export 'package:visual_discrimination_app/Enums/TimeOutCodes.dart';
export 'package:visual_discrimination_app/Models/TrialElement.dart';
export 'package:visual_discrimination_app/Models/ResultElement.dart';

// Pages
export 'package:visual_discrimination_app/Pages/AddPage.dart';
export 'package:visual_discrimination_app/Pages/DisplayPage.dart';
export 'package:visual_discrimination_app/Pages/EditPage.dart';
export 'package:visual_discrimination_app/Pages/HomePage.dart';
export 'package:visual_discrimination_app/Pages/LoginPage.dart';
export 'package:visual_discrimination_app/Pages/PracticePage.dart';
export 'package:visual_discrimination_app/Pages/TrialPage.dart';
