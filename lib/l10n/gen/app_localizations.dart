import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_nl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('nl'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'InnoBeweegLab - Field Observation System'**
  String get appTitle;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageDutch.
  ///
  /// In en, this message translates to:
  /// **'Dutch'**
  String get languageDutch;

  /// No description provided for @profileReauthRequired.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again to update your name.'**
  String get profileReauthRequired;

  /// No description provided for @profileNameEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Name cannot be empty.'**
  String get profileNameEmptyError;

  /// No description provided for @profileNothingToUpdate.
  ///
  /// In en, this message translates to:
  /// **'Nothing to update.'**
  String get profileNothingToUpdate;

  /// No description provided for @profileNameUpdated.
  ///
  /// In en, this message translates to:
  /// **'Name updated.'**
  String get profileNameUpdated;

  /// No description provided for @profileUpdateNameError.
  ///
  /// In en, this message translates to:
  /// **'Unable to update name right now.'**
  String get profileUpdateNameError;

  /// No description provided for @profileNoEmailError.
  ///
  /// In en, this message translates to:
  /// **'No email associated with this account.'**
  String get profileNoEmailError;

  /// No description provided for @profileResetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'If an account exists for {email}, a reset link is on the way.'**
  String profileResetLinkSent(Object email);

  /// No description provided for @profileResetFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not send reset email.'**
  String get profileResetFailed;

  /// No description provided for @profileLogoutError.
  ///
  /// In en, this message translates to:
  /// **'Unable to logout right now. Please try again.'**
  String get profileLogoutError;

  /// No description provided for @profileSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile & Settings'**
  String get profileSettingsTitle;

  /// No description provided for @profileSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileSectionTitle;

  /// No description provided for @profileNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get profileNameLabel;

  /// No description provided for @profileNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get profileNameHint;

  /// No description provided for @profileSaveName.
  ///
  /// In en, this message translates to:
  /// **'Save name'**
  String get profileSaveName;

  /// No description provided for @profileEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileEmailLabel;

  /// No description provided for @profileUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get profileUnavailable;

  /// No description provided for @profileRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get profileRoleLabel;

  /// No description provided for @profileRoleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get profileRoleAdmin;

  /// No description provided for @profileRoleObserver.
  ///
  /// In en, this message translates to:
  /// **'Observer'**
  String get profileRoleObserver;

  /// No description provided for @profileRoleUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown role'**
  String get profileRoleUnknown;

  /// No description provided for @profilePreferencesTitle.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get profilePreferencesTitle;

  /// No description provided for @profileLanguagePreference.
  ///
  /// In en, this message translates to:
  /// **'Language preference'**
  String get profileLanguagePreference;

  /// No description provided for @profileSecurityTitle.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get profileSecurityTitle;

  /// No description provided for @profileSendingReset.
  ///
  /// In en, this message translates to:
  /// **'Sending reset...'**
  String get profileSendingReset;

  /// No description provided for @profileChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get profileChangePassword;

  /// No description provided for @profileLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get profileLogout;

  /// No description provided for @profileShortcutsTitle.
  ///
  /// In en, this message translates to:
  /// **'Shortcuts'**
  String get profileShortcutsTitle;

  /// No description provided for @profileOpenAdminPanel.
  ///
  /// In en, this message translates to:
  /// **'Open Admin Panel'**
  String get profileOpenAdminPanel;

  /// No description provided for @profileAdminPanelSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage projects, observers, and alerts'**
  String get profileAdminPanelSubtitle;

  /// No description provided for @adminNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin notifications'**
  String get adminNotificationsTitle;

  /// No description provided for @notificationsNavTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsNavTitle;

  /// No description provided for @notificationsRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get notificationsRecentActivity;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsMarkAllReadSuccess.
  ///
  /// In en, this message translates to:
  /// **'All notifications marked as read.'**
  String get notificationsMarkAllReadSuccess;

  /// No description provided for @notificationsMarkAllReadFailure.
  ///
  /// In en, this message translates to:
  /// **'Could not mark notifications as read.'**
  String get notificationsMarkAllReadFailure;

  /// No description provided for @notificationsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load notifications right now.'**
  String get notificationsLoadError;

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'You will see new user sign-ups here once they happen.'**
  String get notificationsEmptySubtitle;

  /// No description provided for @relativeJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get relativeJustNow;

  /// No description provided for @relativeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String relativeMinutesAgo(int minutes);

  /// No description provided for @relativeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String relativeHoursAgo(int hours);

  /// No description provided for @commonRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get commonRefresh;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get commonSaveChanges;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonBackToProjects.
  ///
  /// In en, this message translates to:
  /// **'Back to Projects'**
  String get commonBackToProjects;

  /// No description provided for @commonTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get commonTryAgain;

  /// No description provided for @commonEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get commonEmailLabel;

  /// No description provided for @commonPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get commonPasswordLabel;

  /// No description provided for @authCheckingSession.
  ///
  /// In en, this message translates to:
  /// **'Checking your session...'**
  String get authCheckingSession;

  /// No description provided for @authRestoringWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Restoring your workspace...'**
  String get authRestoringWorkspace;

  /// No description provided for @authRestoreError.
  ///
  /// In en, this message translates to:
  /// **'Unable to restore your profile. Please sign in again.'**
  String get authRestoreError;

  /// No description provided for @authReturnToLogin.
  ///
  /// In en, this message translates to:
  /// **'Return to login'**
  String get authReturnToLogin;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// No description provided for @loginErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Unable to login right now. Please try again.'**
  String get loginErrorGeneric;

  /// No description provided for @loginEmailPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'your.email@example.com'**
  String get loginEmailPlaceholder;

  /// No description provided for @loginEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get loginEmailRequired;

  /// No description provided for @loginEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get loginEmailInvalid;

  /// No description provided for @loginPasswordPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get loginPasswordPlaceholder;

  /// No description provided for @loginPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get loginPasswordRequired;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get loginForgotPassword;

  /// No description provided for @loginSubmit.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginSubmit;

  /// No description provided for @loginNoAccountQuestion.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get loginNoAccountQuestion;

  /// No description provided for @loginSignUpCta.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get loginSignUpCta;

  /// No description provided for @loginResetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get loginResetPasswordTitle;

  /// No description provided for @loginResetPasswordBody.
  ///
  /// In en, this message translates to:
  /// **'Enter the email linked to your account. We will send a reset link if an account exists.'**
  String get loginResetPasswordBody;

  /// No description provided for @loginResetEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter the email tied to your account.'**
  String get loginResetEmailRequired;

  /// No description provided for @loginResetSendError.
  ///
  /// In en, this message translates to:
  /// **'Unable to send reset email. Please try again.'**
  String get loginResetSendError;

  /// No description provided for @loginResetSendLink.
  ///
  /// In en, this message translates to:
  /// **'Send link'**
  String get loginResetSendLink;

  /// No description provided for @loginResetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'If an account exists for {email}, a reset link is on the way.'**
  String loginResetLinkSent(Object email);

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Field Observation System'**
  String get appTagline;

  /// No description provided for @observerWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, {firstName}!'**
  String observerWelcomeBack(Object firstName);

  /// No description provided for @observerSelectProjectPrompt.
  ///
  /// In en, this message translates to:
  /// **'Select a project to begin your observation'**
  String get observerSelectProjectPrompt;

  /// No description provided for @profileLoggedInAs.
  ///
  /// In en, this message translates to:
  /// **'Logged in as'**
  String get profileLoggedInAs;

  /// No description provided for @profileMenuProfileSettings.
  ///
  /// In en, this message translates to:
  /// **'Profile & Settings'**
  String get profileMenuProfileSettings;

  /// No description provided for @profileMenuNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profileMenuNotifications;

  /// No description provided for @profileMenuAdminPanel.
  ///
  /// In en, this message translates to:
  /// **'Admin Panel'**
  String get profileMenuAdminPanel;

  /// No description provided for @profileMenuProjectMap.
  ///
  /// In en, this message translates to:
  /// **'Project Map'**
  String get profileMenuProjectMap;

  /// No description provided for @profileMenuProjects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get profileMenuProjects;

  /// No description provided for @profileMenuObserver.
  ///
  /// In en, this message translates to:
  /// **'Observer'**
  String get profileMenuObserver;

  /// No description provided for @projectsNeedHelp.
  ///
  /// In en, this message translates to:
  /// **'Need help? Contact your administrator for support'**
  String get projectsNeedHelp;

  /// No description provided for @signupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get signupTitle;

  /// No description provided for @signupFirstNameLabel.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get signupFirstNameLabel;

  /// No description provided for @signupFirstNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter your first name'**
  String get signupFirstNamePlaceholder;

  /// No description provided for @signupLastNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get signupLastNameLabel;

  /// No description provided for @signupLastNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter your last name'**
  String get signupLastNamePlaceholder;

  /// No description provided for @signupEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get signupEmailLabel;

  /// No description provided for @signupEmailPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'your.email@example.com'**
  String get signupEmailPlaceholder;

  /// No description provided for @signupEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get signupEmailRequired;

  /// No description provided for @signupEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get signupEmailInvalid;

  /// No description provided for @signupPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get signupPasswordLabel;

  /// No description provided for @signupPasswordPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Create a password'**
  String get signupPasswordPlaceholder;

  /// No description provided for @signupPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get signupPasswordRequired;

  /// No description provided for @signupPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get signupPasswordTooShort;

  /// No description provided for @signupPasswordConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get signupPasswordConfirmLabel;

  /// No description provided for @signupPasswordConfirmPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get signupPasswordConfirmPlaceholder;

  /// No description provided for @signupPasswordConfirmRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get signupPasswordConfirmRequired;

  /// No description provided for @signupSubmit.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get signupSubmit;

  /// No description provided for @signupRoleInfoPrefix.
  ///
  /// In en, this message translates to:
  /// **'New accounts are assigned the '**
  String get signupRoleInfoPrefix;

  /// No description provided for @signupRoleName.
  ///
  /// In en, this message translates to:
  /// **'Observer role'**
  String get signupRoleName;

  /// No description provided for @signupRoleInfoSuffix.
  ///
  /// In en, this message translates to:
  /// **' by default. Admin privileges must be granted by the database owner.'**
  String get signupRoleInfoSuffix;

  /// No description provided for @signupAlreadyHaveAccountPrefix.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get signupAlreadyHaveAccountPrefix;

  /// No description provided for @signupLoginCta.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get signupLoginCta;

  /// No description provided for @observerSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Session Summary'**
  String get observerSummaryTitle;

  /// No description provided for @observerSummaryEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No observations recorded'**
  String get observerSummaryEmptyTitle;

  /// No description provided for @observerSummaryEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'No observations this session. Submit to return to your projects.'**
  String get observerSummaryEmptySubtitle;

  /// No description provided for @observerSummaryTotalRecorded.
  ///
  /// In en, this message translates to:
  /// **'Total Recorded'**
  String get observerSummaryTotalRecorded;

  /// No description provided for @observerSummaryEntries.
  ///
  /// In en, this message translates to:
  /// **'{count} entries'**
  String observerSummaryEntries(int count);

  /// No description provided for @observerSummaryIndividuals.
  ///
  /// In en, this message translates to:
  /// **'Individuals'**
  String get observerSummaryIndividuals;

  /// No description provided for @observerSummaryGroups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get observerSummaryGroups;

  /// No description provided for @observerSummaryGroupObservations.
  ///
  /// In en, this message translates to:
  /// **'Group Observations'**
  String get observerSummaryGroupObservations;

  /// No description provided for @observerSummaryDemographics.
  ///
  /// In en, this message translates to:
  /// **'Demographics'**
  String get observerSummaryDemographics;

  /// No description provided for @observerSummaryMales.
  ///
  /// In en, this message translates to:
  /// **'Males'**
  String get observerSummaryMales;

  /// No description provided for @observerSummaryFemales.
  ///
  /// In en, this message translates to:
  /// **'Females'**
  String get observerSummaryFemales;

  /// No description provided for @observerSummaryChildren.
  ///
  /// In en, this message translates to:
  /// **'Children'**
  String get observerSummaryChildren;

  /// No description provided for @observerSummaryActivityLevels.
  ///
  /// In en, this message translates to:
  /// **'Activity Levels'**
  String get observerSummaryActivityLevels;

  /// No description provided for @observerSummaryActivitySedentary.
  ///
  /// In en, this message translates to:
  /// **'Sedentary'**
  String get observerSummaryActivitySedentary;

  /// No description provided for @observerSummaryActivityMoving.
  ///
  /// In en, this message translates to:
  /// **'Moving'**
  String get observerSummaryActivityMoving;

  /// No description provided for @observerSummaryActivityIntense.
  ///
  /// In en, this message translates to:
  /// **'Intense'**
  String get observerSummaryActivityIntense;

  /// No description provided for @observerSummarySessionDetails.
  ///
  /// In en, this message translates to:
  /// **'Session Details'**
  String get observerSummarySessionDetails;

  /// No description provided for @observerSummaryLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get observerSummaryLocation;

  /// No description provided for @observerSummaryDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get observerSummaryDate;

  /// No description provided for @observerSummaryTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get observerSummaryTime;

  /// No description provided for @observerSummaryWeather.
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get observerSummaryWeather;

  /// No description provided for @observerSummarySubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit Session'**
  String get observerSummarySubmit;

  /// No description provided for @weatherCloudy.
  ///
  /// In en, this message translates to:
  /// **'cloudy'**
  String get weatherCloudy;

  /// No description provided for @weatherRainy.
  ///
  /// In en, this message translates to:
  /// **'rainy'**
  String get weatherRainy;

  /// No description provided for @weatherSunny.
  ///
  /// In en, this message translates to:
  /// **'sunny'**
  String get weatherSunny;

  /// No description provided for @observerSummaryLocationMultiple.
  ///
  /// In en, this message translates to:
  /// **'Multiple'**
  String get observerSummaryLocationMultiple;

  /// No description provided for @observerSummaryLocationCruyff.
  ///
  /// In en, this message translates to:
  /// **'C - Cruyff Court'**
  String get observerSummaryLocationCruyff;

  /// No description provided for @observerSummaryLocationBasketball.
  ///
  /// In en, this message translates to:
  /// **'B - Basketball Field'**
  String get observerSummaryLocationBasketball;

  /// No description provided for @observerSummaryLocationGrass.
  ///
  /// In en, this message translates to:
  /// **'G - Grass Field'**
  String get observerSummaryLocationGrass;

  /// No description provided for @observerSummaryLocationCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get observerSummaryLocationCustom;

  /// No description provided for @observerFinishSession.
  ///
  /// In en, this message translates to:
  /// **'Finish Session'**
  String get observerFinishSession;

  /// No description provided for @observerSubmitGroup.
  ///
  /// In en, this message translates to:
  /// **'Submit Group'**
  String get observerSubmitGroup;

  /// No description provided for @observerSubmitPerson.
  ///
  /// In en, this message translates to:
  /// **'Submit Person'**
  String get observerSubmitPerson;

  /// No description provided for @observerNoOptionsConfigured.
  ///
  /// In en, this message translates to:
  /// **'No options configured.'**
  String get observerNoOptionsConfigured;

  /// No description provided for @observerOtherOption.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get observerOtherOption;

  /// No description provided for @observerNoProjectTitle.
  ///
  /// In en, this message translates to:
  /// **'No project selected'**
  String get observerNoProjectTitle;

  /// No description provided for @observerNoProjectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a project from the list to start recording observations.'**
  String get observerNoProjectSubtitle;

  /// No description provided for @observerBackToProjectList.
  ///
  /// In en, this message translates to:
  /// **'Back to projects'**
  String get observerBackToProjectList;

  /// No description provided for @observerAdditionalNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Additional notes...'**
  String get observerAdditionalNotesHint;

  /// No description provided for @observerActivityNotesPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Describe what is happening'**
  String get observerActivityNotesPlaceholder;

  /// No description provided for @observerRemarksPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Any extra remarks?'**
  String get observerRemarksPlaceholder;

  /// No description provided for @observerDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get observerDateLabel;

  /// No description provided for @observerTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get observerTimeLabel;

  /// No description provided for @observerModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Observation Mode'**
  String get observerModeLabel;

  /// No description provided for @observerModeIndividual.
  ///
  /// In en, this message translates to:
  /// **'Individual'**
  String get observerModeIndividual;

  /// No description provided for @observerModeGroup.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get observerModeGroup;

  /// No description provided for @observerNoFieldsConfigured.
  ///
  /// In en, this message translates to:
  /// **'No observation fields are configured for this project.'**
  String get observerNoFieldsConfigured;

  /// No description provided for @observerSelectProject.
  ///
  /// In en, this message translates to:
  /// **'Select a project before recording observations.'**
  String get observerSelectProject;

  /// No description provided for @observerPleaseSignIn.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again to continue.'**
  String get observerPleaseSignIn;

  /// No description provided for @observerEnterNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a number'**
  String get observerEnterNumber;

  /// No description provided for @observerPleaseSelectOption.
  ///
  /// In en, this message translates to:
  /// **'Please select an option'**
  String get observerPleaseSelectOption;

  /// No description provided for @observerGenderDistribution.
  ///
  /// In en, this message translates to:
  /// **'Gender Distribution'**
  String get observerGenderDistribution;

  /// No description provided for @observerGenderDistributionHelper.
  ///
  /// In en, this message translates to:
  /// **'How many people of each gender?'**
  String get observerGenderDistributionHelper;

  /// No description provided for @observerAgeDistribution.
  ///
  /// In en, this message translates to:
  /// **'Age Distribution'**
  String get observerAgeDistribution;

  /// No description provided for @observerAgeDistributionHelper.
  ///
  /// In en, this message translates to:
  /// **'How many people in each age range?'**
  String get observerAgeDistributionHelper;

  /// No description provided for @observerGenderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get observerGenderMale;

  /// No description provided for @observerGenderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get observerGenderFemale;

  /// No description provided for @observerAge11AndYounger.
  ///
  /// In en, this message translates to:
  /// **'11 and younger'**
  String get observerAge11AndYounger;

  /// No description provided for @observerAge12to17.
  ///
  /// In en, this message translates to:
  /// **'12 – 17'**
  String get observerAge12to17;

  /// No description provided for @observerAge18to24.
  ///
  /// In en, this message translates to:
  /// **'18 – 24'**
  String get observerAge18to24;

  /// No description provided for @observerAge25to44.
  ///
  /// In en, this message translates to:
  /// **'25 – 44'**
  String get observerAge25to44;

  /// No description provided for @observerAge45to64.
  ///
  /// In en, this message translates to:
  /// **'45 – 64'**
  String get observerAge45to64;

  /// No description provided for @observerAge65Plus.
  ///
  /// In en, this message translates to:
  /// **'65+'**
  String get observerAge65Plus;

  /// No description provided for @observerProjectsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Projects'**
  String get observerProjectsTitle;

  /// No description provided for @observerProjectsAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {{count} project available} other {{count} projects available}}'**
  String observerProjectsAvailable(int count);

  /// No description provided for @observerProjectsSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search projects...'**
  String get observerProjectsSearchPlaceholder;

  /// No description provided for @observerProjectsEmptySearchTitle.
  ///
  /// In en, this message translates to:
  /// **'No projects found'**
  String get observerProjectsEmptySearchTitle;

  /// No description provided for @observerProjectsEmptySearchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search terms'**
  String get observerProjectsEmptySearchSubtitle;

  /// No description provided for @observerProjectsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Projects Assigned'**
  String get observerProjectsEmptyTitle;

  /// No description provided for @observerProjectsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any observation projects assigned yet.\nPlease contact your administrator to get access to projects.'**
  String get observerProjectsEmptySubtitle;

  /// No description provided for @observerProjectsRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh projects'**
  String get observerProjectsRefresh;

  /// No description provided for @projectMapTitle.
  ///
  /// In en, this message translates to:
  /// **'Project Map'**
  String get projectMapTitle;

  /// No description provided for @observerSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Observation Saved!'**
  String get observerSuccessTitle;

  /// No description provided for @observerSuccessPerson.
  ///
  /// In en, this message translates to:
  /// **'Person #{personId} has been recorded.'**
  String observerSuccessPerson(Object personId);

  /// No description provided for @observerSuccessGroup.
  ///
  /// In en, this message translates to:
  /// **'Group of {groupSize} people has been recorded.'**
  String observerSuccessGroup(int groupSize);

  /// No description provided for @observerSuccessPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing next observation...'**
  String get observerSuccessPreparing;

  /// No description provided for @exportSheetName.
  ///
  /// In en, this message translates to:
  /// **'Observations'**
  String get exportSheetName;

  /// No description provided for @exportProjectLabel.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get exportProjectLabel;

  /// No description provided for @exportLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get exportLocationLabel;

  /// No description provided for @exportLocationNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get exportLocationNotSet;

  /// No description provided for @exportExportedAt.
  ///
  /// In en, this message translates to:
  /// **'Exported At'**
  String get exportExportedAt;

  /// No description provided for @exportObservationCount.
  ///
  /// In en, this message translates to:
  /// **'Observation Count'**
  String get exportObservationCount;

  /// No description provided for @exportHeaderPersonId.
  ///
  /// In en, this message translates to:
  /// **'Person ID'**
  String get exportHeaderPersonId;

  /// No description provided for @exportHeaderMode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get exportHeaderMode;

  /// No description provided for @exportHeaderTimestamp.
  ///
  /// In en, this message translates to:
  /// **'Timestamp'**
  String get exportHeaderTimestamp;

  /// No description provided for @exportHeaderObserverEmail.
  ///
  /// In en, this message translates to:
  /// **'Observer Email'**
  String get exportHeaderObserverEmail;

  /// No description provided for @exportHeaderObserverUid.
  ///
  /// In en, this message translates to:
  /// **'Observer UID'**
  String get exportHeaderObserverUid;

  /// No description provided for @exportHeaderGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get exportHeaderGender;

  /// No description provided for @exportHeaderAgeGroup.
  ///
  /// In en, this message translates to:
  /// **'Age Group'**
  String get exportHeaderAgeGroup;

  /// No description provided for @exportHeaderSocialContext.
  ///
  /// In en, this message translates to:
  /// **'Social Context'**
  String get exportHeaderSocialContext;

  /// No description provided for @exportHeaderActivityLevel.
  ///
  /// In en, this message translates to:
  /// **'Activity Level'**
  String get exportHeaderActivityLevel;

  /// No description provided for @exportHeaderActivityType.
  ///
  /// In en, this message translates to:
  /// **'Activity Type'**
  String get exportHeaderActivityType;

  /// No description provided for @exportHeaderLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get exportHeaderLocation;

  /// No description provided for @exportHeaderLocationTypeId.
  ///
  /// In en, this message translates to:
  /// **'Location Type ID'**
  String get exportHeaderLocationTypeId;

  /// No description provided for @exportHeaderGroupSize.
  ///
  /// In en, this message translates to:
  /// **'Group Size'**
  String get exportHeaderGroupSize;

  /// No description provided for @exportHeaderGenderMix.
  ///
  /// In en, this message translates to:
  /// **'Gender Mix'**
  String get exportHeaderGenderMix;

  /// No description provided for @exportHeaderAgeMix.
  ///
  /// In en, this message translates to:
  /// **'Age Mix'**
  String get exportHeaderAgeMix;

  /// No description provided for @exportHeaderNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get exportHeaderNotes;

  /// No description provided for @exportSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Excel export saved to your device.'**
  String get exportSuccessMessage;

  /// No description provided for @exportErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Unable to export observations right now.'**
  String get exportErrorMessage;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @projectMapLocationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Location unavailable'**
  String get projectMapLocationUnavailable;

  /// No description provided for @projectMapOpenInAdmin.
  ///
  /// In en, this message translates to:
  /// **'Open in Admin'**
  String get projectMapOpenInAdmin;

  /// No description provided for @projectMapNoMappableProjects.
  ///
  /// In en, this message translates to:
  /// **'No projects with mappable locations yet.'**
  String get projectMapNoMappableProjects;

  /// No description provided for @projectMapProjectCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {{count} project} other {{count} projects}}'**
  String projectMapProjectCount(int count);

  /// No description provided for @projectMapLegendTitle.
  ///
  /// In en, this message translates to:
  /// **'Legend'**
  String get projectMapLegendTitle;

  /// No description provided for @projectMapLegendActive.
  ///
  /// In en, this message translates to:
  /// **'Active projects'**
  String get projectMapLegendActive;

  /// No description provided for @projectMapLegendFinished.
  ///
  /// In en, this message translates to:
  /// **'Finished projects'**
  String get projectMapLegendFinished;

  /// No description provided for @projectMapLegendArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived projects'**
  String get projectMapLegendArchived;

  /// No description provided for @projectsLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading projects...'**
  String get projectsLoading;

  /// No description provided for @projectsLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load projects'**
  String get projectsLoadErrorTitle;

  /// No description provided for @projectsRefreshTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh projects'**
  String get projectsRefreshTooltip;

  /// No description provided for @adminStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get adminStatusActive;

  /// No description provided for @adminStatusFinished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get adminStatusFinished;

  /// No description provided for @adminStatusArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get adminStatusArchived;

  /// No description provided for @adminSectionGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get adminSectionGeneral;

  /// No description provided for @adminSectionObservers.
  ///
  /// In en, this message translates to:
  /// **'Observers'**
  String get adminSectionObservers;

  /// No description provided for @adminSectionFields.
  ///
  /// In en, this message translates to:
  /// **'Fields'**
  String get adminSectionFields;

  /// No description provided for @adminSectionData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get adminSectionData;

  /// No description provided for @adminManageProjectsTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Projects'**
  String get adminManageProjectsTitle;

  /// No description provided for @adminManageProjectsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create and organize observation projects, assign observers, and monitor data collection'**
  String get adminManageProjectsSubtitle;

  /// No description provided for @adminCreateNewProject.
  ///
  /// In en, this message translates to:
  /// **'Create New Project'**
  String get adminCreateNewProject;

  /// No description provided for @adminNoProjectsTitle.
  ///
  /// In en, this message translates to:
  /// **'No {status} projects yet'**
  String adminNoProjectsTitle(Object status);

  /// No description provided for @adminNoProjectsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your first project to get started'**
  String get adminNoProjectsSubtitle;

  /// No description provided for @adminStatusChipLabel.
  ///
  /// In en, this message translates to:
  /// **'{status} ({count})'**
  String adminStatusChipLabel(Object status, int count);

  /// No description provided for @adminProjectCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Project created successfully!'**
  String get adminProjectCreatedSuccess;

  /// No description provided for @adminStatusProjectsTitle.
  ///
  /// In en, this message translates to:
  /// **'{status} Projects ({count})'**
  String adminStatusProjectsTitle(Object status, int count);

  /// No description provided for @adminNewProjectNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Project Name'**
  String get adminNewProjectNameLabel;

  /// No description provided for @adminNewProjectNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Parkstraat Observation Site'**
  String get adminNewProjectNameHint;

  /// No description provided for @adminNewProjectMainLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Main Location'**
  String get adminNewProjectMainLocationLabel;

  /// No description provided for @adminNewProjectMainLocationHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Parkstraat, Amsterdam'**
  String get adminNewProjectMainLocationHint;

  /// No description provided for @adminNoSuggestionsFound.
  ///
  /// In en, this message translates to:
  /// **'No suggestions found'**
  String get adminNoSuggestionsFound;

  /// No description provided for @adminDescriptionOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get adminDescriptionOptionalLabel;

  /// No description provided for @adminDescriptionOptionalHint.
  ///
  /// In en, this message translates to:
  /// **'Add project description or notes...'**
  String get adminDescriptionOptionalHint;

  /// No description provided for @adminCreating.
  ///
  /// In en, this message translates to:
  /// **'Creating...'**
  String get adminCreating;

  /// No description provided for @adminCreateProject.
  ///
  /// In en, this message translates to:
  /// **'Create Project'**
  String get adminCreateProject;

  /// No description provided for @adminLocationTypesTitle.
  ///
  /// In en, this message translates to:
  /// **'Location Types'**
  String get adminLocationTypesTitle;

  /// No description provided for @adminLocationTypesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select all location types available at this site'**
  String get adminLocationTypesSubtitle;

  /// No description provided for @adminCustomLocationPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Add a custom location... (Enter or Add)'**
  String get adminCustomLocationPlaceholder;

  /// No description provided for @adminAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get adminAdd;

  /// No description provided for @adminHiddenLocationTypes.
  ///
  /// In en, this message translates to:
  /// **'Hidden location types:'**
  String get adminHiddenLocationTypes;

  /// No description provided for @adminAssignObserversTitle.
  ///
  /// In en, this message translates to:
  /// **'Assign Observers (Optional)'**
  String get adminAssignObserversTitle;

  /// No description provided for @adminAssignObserversSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add team members who can collect observations for this project'**
  String get adminAssignObserversSubtitle;

  /// No description provided for @adminAddObserver.
  ///
  /// In en, this message translates to:
  /// **'Add Observer'**
  String get adminAddObserver;

  /// No description provided for @adminSearchObserversPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search observers by name or email...'**
  String get adminSearchObserversPlaceholder;

  /// No description provided for @adminNoObserversFound.
  ///
  /// In en, this message translates to:
  /// **'No observers found'**
  String get adminNoObserversFound;

  /// No description provided for @adminDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get adminDone;

  /// No description provided for @adminNoObserversAssigned.
  ///
  /// In en, this message translates to:
  /// **'No observers assigned yet. You can add them later.'**
  String get adminNoObserversAssigned;

  /// No description provided for @adminProjectMainLocationUnset.
  ///
  /// In en, this message translates to:
  /// **'Main location not set'**
  String get adminProjectMainLocationUnset;

  /// No description provided for @adminMainLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Main Location'**
  String get adminMainLocationTitle;

  /// No description provided for @adminMainLocationDescription.
  ///
  /// In en, this message translates to:
  /// **'Specify the main site this project covers. Individual location types below should describe areas inside this location.'**
  String get adminMainLocationDescription;

  /// No description provided for @adminMainLocationHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Parkstraat, Amsterdam Noord'**
  String get adminMainLocationHint;

  /// No description provided for @adminMainLocationSave.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get adminMainLocationSave;

  /// No description provided for @adminMainLocationSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get adminMainLocationSaving;

  /// No description provided for @adminProjectObservationCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {{count} observation} other {{count} observations}}'**
  String adminProjectObservationCount(int count);

  /// No description provided for @adminProjectObserverCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {{count} observer} other {{count} observers}}'**
  String adminProjectObserverCount(int count);

  /// No description provided for @adminDeleteWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'You are about to permanently delete this project. This will remove:'**
  String get adminDeleteWarningTitle;

  /// No description provided for @adminDeleteRemoveObservations.
  ///
  /// In en, this message translates to:
  /// **'• {count, plural, one {{count} observation} other {{count} observations}}'**
  String adminDeleteRemoveObservations(int count);

  /// No description provided for @adminDeleteRemoveObservers.
  ///
  /// In en, this message translates to:
  /// **'• All assigned observers'**
  String get adminDeleteRemoveObservers;

  /// No description provided for @adminDeleteRemoveData.
  ///
  /// In en, this message translates to:
  /// **'• All project data and settings'**
  String get adminDeleteRemoveData;

  /// No description provided for @adminDeleteIrreversible.
  ///
  /// In en, this message translates to:
  /// **'This data cannot be recovered once deleted.'**
  String get adminDeleteIrreversible;

  /// No description provided for @adminDeleteConfirmQuestion.
  ///
  /// In en, this message translates to:
  /// **'Are you absolutely sure you want to continue?'**
  String get adminDeleteConfirmQuestion;

  /// No description provided for @adminDeleteConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Yes, Delete Project'**
  String get adminDeleteConfirmButton;

  /// No description provided for @adminDeleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Project?'**
  String get adminDeleteDialogTitle;

  /// No description provided for @adminDeleteWarningHeader.
  ///
  /// In en, this message translates to:
  /// **'⚠️ WARNING: This action cannot be reversed!'**
  String get adminDeleteWarningHeader;

  /// No description provided for @adminLoadingProjects.
  ///
  /// In en, this message translates to:
  /// **'Loading projects...'**
  String get adminLoadingProjects;

  /// No description provided for @adminChangeStatusTooltip.
  ///
  /// In en, this message translates to:
  /// **'Change project status'**
  String get adminChangeStatusTooltip;

  /// No description provided for @adminStatusOptionCurrent.
  ///
  /// In en, this message translates to:
  /// **'{status} (current)'**
  String adminStatusOptionCurrent(Object status);

  /// No description provided for @adminObserverAssignedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {{count} observer assigned} other {{count} observers assigned}}'**
  String adminObserverAssignedCount(int count);

  /// No description provided for @adminLocationTypesHeader.
  ///
  /// In en, this message translates to:
  /// **'Location Types'**
  String get adminLocationTypesHeader;

  /// No description provided for @adminAddLocation.
  ///
  /// In en, this message translates to:
  /// **'Add Location'**
  String get adminAddLocation;

  /// No description provided for @adminAddLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Add location'**
  String get adminAddLocationHint;

  /// No description provided for @adminNoLocationTypes.
  ///
  /// In en, this message translates to:
  /// **'No location types configured'**
  String get adminNoLocationTypes;

  /// No description provided for @adminAssignedObservers.
  ///
  /// In en, this message translates to:
  /// **'Assigned Observers'**
  String get adminAssignedObservers;

  /// No description provided for @adminObserverSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search observers by name or email...'**
  String get adminObserverSearchPlaceholder;

  /// No description provided for @adminObserversAllAssigned.
  ///
  /// In en, this message translates to:
  /// **'All observers are already assigned'**
  String get adminObserversAllAssigned;

  /// No description provided for @adminNoObserversFoundSelector.
  ///
  /// In en, this message translates to:
  /// **'No observers found'**
  String get adminNoObserversFoundSelector;

  /// No description provided for @adminNoObserversAssignedTitle.
  ///
  /// In en, this message translates to:
  /// **'No observers assigned yet'**
  String get adminNoObserversAssignedTitle;

  /// No description provided for @adminNoObserversAssignedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Click \"Add Observer\" to assign team members'**
  String get adminNoObserversAssignedSubtitle;

  /// No description provided for @adminClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get adminClearAll;

  /// No description provided for @adminEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get adminEdit;

  /// No description provided for @adminEntriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Entries'**
  String get adminEntriesLabel;

  /// No description provided for @adminEntriesOption.
  ///
  /// In en, this message translates to:
  /// **'{count} entries'**
  String adminEntriesOption(Object count);

  /// No description provided for @adminNoFieldsTitle.
  ///
  /// In en, this message translates to:
  /// **'No fields configured yet.'**
  String get adminNoFieldsTitle;

  /// No description provided for @adminNoFieldsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your first custom field or restore the default template.'**
  String get adminNoFieldsSubtitle;

  /// No description provided for @adminUnsavedFieldsTitle.
  ///
  /// In en, this message translates to:
  /// **'Unsaved field changes'**
  String get adminUnsavedFieldsTitle;

  /// No description provided for @adminUnsavedFieldsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You made edits that are not saved yet.'**
  String get adminUnsavedFieldsSubtitle;

  /// No description provided for @adminUnsavedFieldsDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Save your changes before leaving this page or discard them.'**
  String get adminUnsavedFieldsDialogBody;

  /// No description provided for @adminDiscardChanges.
  ///
  /// In en, this message translates to:
  /// **'Discard changes'**
  String get adminDiscardChanges;

  /// No description provided for @adminFieldStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get adminFieldStandard;

  /// No description provided for @adminFieldCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get adminFieldCustom;

  /// No description provided for @adminEditObservationTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Observation'**
  String get adminEditObservationTitle;

  /// No description provided for @adminPersonIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Person ID'**
  String get adminPersonIdLabel;

  /// No description provided for @adminPersonIdHint.
  ///
  /// In en, this message translates to:
  /// **'Enter person ID'**
  String get adminPersonIdHint;

  /// No description provided for @adminAgeGroupLabel.
  ///
  /// In en, this message translates to:
  /// **'Age Group'**
  String get adminAgeGroupLabel;

  /// No description provided for @adminSocialContextLabel.
  ///
  /// In en, this message translates to:
  /// **'Social Context'**
  String get adminSocialContextLabel;

  /// No description provided for @adminActivityLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Activity Level'**
  String get adminActivityLevelLabel;

  /// No description provided for @adminActivityTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Activity Type'**
  String get adminActivityTypeLabel;

  /// No description provided for @adminGenderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get adminGenderMale;

  /// No description provided for @adminGenderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get adminGenderFemale;

  /// No description provided for @adminAgeChild.
  ///
  /// In en, this message translates to:
  /// **'Child'**
  String get adminAgeChild;

  /// No description provided for @adminAgeTeen.
  ///
  /// In en, this message translates to:
  /// **'Teen'**
  String get adminAgeTeen;

  /// No description provided for @adminAgeAdult.
  ///
  /// In en, this message translates to:
  /// **'Adult'**
  String get adminAgeAdult;

  /// No description provided for @adminAgeSenior.
  ///
  /// In en, this message translates to:
  /// **'Senior'**
  String get adminAgeSenior;

  /// No description provided for @adminSocialAlone.
  ///
  /// In en, this message translates to:
  /// **'Alone'**
  String get adminSocialAlone;

  /// No description provided for @adminSocialTogether.
  ///
  /// In en, this message translates to:
  /// **'Together'**
  String get adminSocialTogether;

  /// No description provided for @adminActivityLevelSitting.
  ///
  /// In en, this message translates to:
  /// **'Sitting'**
  String get adminActivityLevelSitting;

  /// No description provided for @adminActivityLevelMoving.
  ///
  /// In en, this message translates to:
  /// **'Moving'**
  String get adminActivityLevelMoving;

  /// No description provided for @adminActivityLevelIntense.
  ///
  /// In en, this message translates to:
  /// **'Intense'**
  String get adminActivityLevelIntense;

  /// No description provided for @adminActivityTypeOrganized.
  ///
  /// In en, this message translates to:
  /// **'Organized'**
  String get adminActivityTypeOrganized;

  /// No description provided for @adminActivityTypeUnorganized.
  ///
  /// In en, this message translates to:
  /// **'Unorganized'**
  String get adminActivityTypeUnorganized;

  /// No description provided for @adminEditStandardField.
  ///
  /// In en, this message translates to:
  /// **'Edit Standard Field'**
  String get adminEditStandardField;

  /// No description provided for @adminEditCustomField.
  ///
  /// In en, this message translates to:
  /// **'Edit Custom Field'**
  String get adminEditCustomField;

  /// No description provided for @adminFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get adminFieldLabel;

  /// No description provided for @adminHelperTextOptional.
  ///
  /// In en, this message translates to:
  /// **'Helper text (optional)'**
  String get adminHelperTextOptional;

  /// No description provided for @adminTextFieldSettings.
  ///
  /// In en, this message translates to:
  /// **'Text field settings'**
  String get adminTextFieldSettings;

  /// No description provided for @adminPlaceholderLabel.
  ///
  /// In en, this message translates to:
  /// **'Placeholder'**
  String get adminPlaceholderLabel;

  /// No description provided for @adminMaxLengthOptional.
  ///
  /// In en, this message translates to:
  /// **'Max length (optional)'**
  String get adminMaxLengthOptional;

  /// No description provided for @adminAllowMultilineInput.
  ///
  /// In en, this message translates to:
  /// **'Allow multiline input'**
  String get adminAllowMultilineInput;

  /// No description provided for @adminOptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get adminOptionsTitle;

  /// No description provided for @adminAddOption.
  ///
  /// In en, this message translates to:
  /// **'Add option'**
  String get adminAddOption;

  /// No description provided for @adminRemoveOption.
  ///
  /// In en, this message translates to:
  /// **'Remove option'**
  String get adminRemoveOption;

  /// No description provided for @adminAllowMultipleValues.
  ///
  /// In en, this message translates to:
  /// **'Allow selecting multiple values'**
  String get adminAllowMultipleValues;

  /// No description provided for @adminAudienceIndividual.
  ///
  /// In en, this message translates to:
  /// **'Individual'**
  String get adminAudienceIndividual;

  /// No description provided for @adminAudienceGroup.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get adminAudienceGroup;

  /// No description provided for @adminAudienceBoth.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get adminAudienceBoth;

  /// No description provided for @adminOptionNumber.
  ///
  /// In en, this message translates to:
  /// **'Option {index}'**
  String adminOptionNumber(int index);

  /// No description provided for @adminOptionFallback.
  ///
  /// In en, this message translates to:
  /// **'Option'**
  String get adminOptionFallback;

  /// No description provided for @adminFieldLabelRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Field label is required.'**
  String get adminFieldLabelRequiredError;

  /// No description provided for @adminOptionMinimumError.
  ///
  /// In en, this message translates to:
  /// **'Please provide at least two options.'**
  String get adminOptionMinimumError;

  /// No description provided for @adminFieldTypeTextInput.
  ///
  /// In en, this message translates to:
  /// **'Text input'**
  String get adminFieldTypeTextInput;

  /// No description provided for @adminFieldTypeNumber.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get adminFieldTypeNumber;

  /// No description provided for @adminFieldTypeDropdownLegacy.
  ///
  /// In en, this message translates to:
  /// **'Dropdown (legacy)'**
  String get adminFieldTypeDropdownLegacy;

  /// No description provided for @adminFieldTypeMultiSelect.
  ///
  /// In en, this message translates to:
  /// **'Multi-select'**
  String get adminFieldTypeMultiSelect;

  /// No description provided for @adminFieldTypeCheckbox.
  ///
  /// In en, this message translates to:
  /// **'Checkbox'**
  String get adminFieldTypeCheckbox;

  /// No description provided for @adminFieldTypeDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get adminFieldTypeDate;

  /// No description provided for @adminFieldTypeTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get adminFieldTypeTime;

  /// No description provided for @adminFieldTypeRating.
  ///
  /// In en, this message translates to:
  /// **'Rating scale'**
  String get adminFieldTypeRating;

  /// No description provided for @adminObservationsRecorded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {{count} observation recorded} other {{count} observations recorded}}'**
  String adminObservationsRecorded(int count);

  /// No description provided for @adminPanelTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin Panel'**
  String get adminPanelTitle;

  /// No description provided for @adminAdjustStatus.
  ///
  /// In en, this message translates to:
  /// **'Adjust status'**
  String get adminAdjustStatus;

  /// No description provided for @adminUpdatingStatus.
  ///
  /// In en, this message translates to:
  /// **'Updating...'**
  String get adminUpdatingStatus;

  /// No description provided for @adminObservationFieldsTitle.
  ///
  /// In en, this message translates to:
  /// **'Observation Fields'**
  String get adminObservationFieldsTitle;

  /// No description provided for @adminObservationFieldsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {{count} field} other {{count} fields}}'**
  String adminObservationFieldsCount(int count);

  /// No description provided for @adminObservationFieldsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reorder, edit, or toggle standard/custom fields. Remember to save changes.'**
  String get adminObservationFieldsSubtitle;

  /// No description provided for @adminAddField.
  ///
  /// In en, this message translates to:
  /// **'Add Field'**
  String get adminAddField;

  /// No description provided for @adminRestoreDefaults.
  ///
  /// In en, this message translates to:
  /// **'Restore defaults'**
  String get adminRestoreDefaults;

  /// No description provided for @adminSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get adminSaving;

  /// No description provided for @adminSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get adminSaveChanges;

  /// No description provided for @adminDeleteFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete field'**
  String get adminDeleteFieldTitle;

  /// No description provided for @adminDeleteFieldMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{label}\"? This cannot be undone.'**
  String adminDeleteFieldMessage(Object label);

  /// No description provided for @adminAdditionalNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Additional notes...'**
  String get adminAdditionalNotesHint;

  /// No description provided for @adminRequiredField.
  ///
  /// In en, this message translates to:
  /// **'Required field'**
  String get adminRequiredField;

  /// No description provided for @adminRequiredFieldSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Observers must provide a value before saving.'**
  String get adminRequiredFieldSubtitle;

  /// No description provided for @adminFieldTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Field type'**
  String get adminFieldTypeLabel;

  /// No description provided for @adminFormVisibility.
  ///
  /// In en, this message translates to:
  /// **'Form visibility'**
  String get adminFormVisibility;

  /// No description provided for @adminObservationDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Observation Data'**
  String get adminObservationDataTitle;

  /// No description provided for @adminExporting.
  ///
  /// In en, this message translates to:
  /// **'Exporting...'**
  String get adminExporting;

  /// No description provided for @adminExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get adminExport;

  /// No description provided for @adminFiltersTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get adminFiltersTitle;

  /// No description provided for @adminRefreshData.
  ///
  /// In en, this message translates to:
  /// **'Refresh data'**
  String get adminRefreshData;

  /// No description provided for @adminFilterGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get adminFilterGender;

  /// No description provided for @adminFilterAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get adminFilterAge;

  /// No description provided for @adminFilterSocial.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get adminFilterSocial;

  /// No description provided for @adminFilterLevel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get adminFilterLevel;

  /// No description provided for @adminFilterLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get adminFilterLocation;

  /// No description provided for @adminNoObservationDataTitle.
  ///
  /// In en, this message translates to:
  /// **'No observation data yet'**
  String get adminNoObservationDataTitle;

  /// No description provided for @adminNoObservationDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Data will appear here once observers start collecting'**
  String get adminNoObservationDataSubtitle;

  /// No description provided for @adminNoFilteredObservationsTitle.
  ///
  /// In en, this message translates to:
  /// **'No observations match your filters'**
  String get adminNoFilteredObservationsTitle;

  /// No description provided for @adminNoFilteredObservationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filter criteria'**
  String get adminNoFilteredObservationsSubtitle;

  /// No description provided for @adminLoadingMore.
  ///
  /// In en, this message translates to:
  /// **'Loading more...'**
  String get adminLoadingMore;

  /// No description provided for @adminLoadOlderObservations.
  ///
  /// In en, this message translates to:
  /// **'Load older observations'**
  String get adminLoadOlderObservations;

  /// No description provided for @adminRecordGroup.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get adminRecordGroup;

  /// No description provided for @adminRecordIndividual.
  ///
  /// In en, this message translates to:
  /// **'Individual'**
  String get adminRecordIndividual;

  /// No description provided for @adminFieldGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get adminFieldGender;

  /// No description provided for @adminFieldAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get adminFieldAge;

  /// No description provided for @adminFieldSocial.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get adminFieldSocial;

  /// No description provided for @adminFieldGroupSize.
  ///
  /// In en, this message translates to:
  /// **'Group Size'**
  String get adminFieldGroupSize;

  /// No description provided for @adminFieldGenderMix.
  ///
  /// In en, this message translates to:
  /// **'Gender Mix'**
  String get adminFieldGenderMix;

  /// No description provided for @adminFieldAgeMix.
  ///
  /// In en, this message translates to:
  /// **'Age Mix'**
  String get adminFieldAgeMix;

  /// No description provided for @adminFieldActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get adminFieldActivity;

  /// No description provided for @adminFieldType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get adminFieldType;

  /// No description provided for @adminFieldLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get adminFieldLocation;

  /// No description provided for @adminFieldEmail.
  ///
  /// In en, this message translates to:
  /// **'Email:'**
  String get adminFieldEmail;

  /// No description provided for @adminFieldNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get adminFieldNotes;

  /// No description provided for @adminNoRecordsCollected.
  ///
  /// In en, this message translates to:
  /// **'No records collected yet'**
  String get adminNoRecordsCollected;

  /// No description provided for @adminFilteredResults.
  ///
  /// In en, this message translates to:
  /// **'Filtered results (showing {count})'**
  String adminFilteredResults(int count);

  /// No description provided for @adminShowingLatest.
  ///
  /// In en, this message translates to:
  /// **'Showing latest {visible} of {total} records'**
  String adminShowingLatest(int visible, int total);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'nl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'nl':
      return AppLocalizationsNl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
