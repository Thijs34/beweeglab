// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'InnoBeweegLab - Field Observation System';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageDutch => 'Dutch';

  @override
  String get profileReauthRequired =>
      'Please sign in again to update your name.';

  @override
  String get profileNameEmptyError => 'Name cannot be empty.';

  @override
  String get profileNothingToUpdate => 'Nothing to update.';

  @override
  String get profileNameUpdated => 'Name updated.';

  @override
  String get profileUpdateNameError => 'Unable to update name right now.';

  @override
  String get profileNoEmailError => 'No email associated with this account.';

  @override
  String profileResetLinkSent(Object email) {
    return 'If an account exists for $email, a reset link is on the way.';
  }

  @override
  String get profileResetFailed => 'Could not send reset email.';

  @override
  String get profileLogoutError =>
      'Unable to logout right now. Please try again.';

  @override
  String get profileSettingsTitle => 'Profile & Settings';

  @override
  String get profileSectionTitle => 'Profile';

  @override
  String get profileNameLabel => 'Name';

  @override
  String get profileNameHint => 'Your name';

  @override
  String get profileSaveName => 'Save name';

  @override
  String get profileEmailLabel => 'Email';

  @override
  String get profileUnavailable => 'Unavailable';

  @override
  String get profileRoleLabel => 'Role';

  @override
  String get profileRoleAdmin => 'Admin';

  @override
  String get profileRoleObserver => 'Observer';

  @override
  String get profileRoleUnknown => 'Unknown role';

  @override
  String get profilePreferencesTitle => 'Preferences';

  @override
  String get profileLanguagePreference => 'Language preference';

  @override
  String get profileSecurityTitle => 'Security';

  @override
  String get profileSendingReset => 'Sending reset...';

  @override
  String get profileChangePassword => 'Change password';

  @override
  String get profileLogout => 'Logout';

  @override
  String get profileShortcutsTitle => 'Shortcuts';

  @override
  String get profileOpenAdminPanel => 'Open Admin Panel';

  @override
  String get profileAdminPanelSubtitle =>
      'Manage projects, observers, and alerts';

  @override
  String get adminNotificationsTitle => 'Admin notifications';

  @override
  String get notificationsNavTitle => 'Notifications';

  @override
  String get notificationsRecentActivity => 'Recent activity';

  @override
  String get notificationsMarkAllRead => 'Mark all read';

  @override
  String get notificationsMarkAllReadSuccess =>
      'All notifications marked as read.';

  @override
  String get notificationsMarkAllReadFailure =>
      'Could not mark notifications as read.';

  @override
  String get notificationsLoadError =>
      'Unable to load notifications right now.';

  @override
  String get notificationsEmptyTitle => 'No notifications yet';

  @override
  String get notificationsEmptySubtitle =>
      'You will see new user sign-ups here once they happen.';

  @override
  String get relativeJustNow => 'Just now';

  @override
  String relativeMinutesAgo(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String relativeHoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String get commonRefresh => 'Refresh';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonSaveChanges => 'Save changes';

  @override
  String get commonDone => 'Done';

  @override
  String get commonBackToProjects => 'Back to Projects';

  @override
  String get commonTryAgain => 'Try again';

  @override
  String get commonEmailLabel => 'Email';

  @override
  String get commonPasswordLabel => 'Password';

  @override
  String get authCheckingSession => 'Checking your session...';

  @override
  String get authRestoringWorkspace => 'Restoring your workspace...';

  @override
  String get authRestoreError =>
      'Unable to restore your profile. Please sign in again.';

  @override
  String get authReturnToLogin => 'Return to login';

  @override
  String get loginTitle => 'Login';

  @override
  String get loginErrorGeneric =>
      'Unable to login right now. Please try again.';

  @override
  String get loginEmailPlaceholder => 'your.email@example.com';

  @override
  String get loginEmailRequired => 'Email is required';

  @override
  String get loginEmailInvalid => 'Please enter a valid email';

  @override
  String get loginPasswordPlaceholder => 'Enter your password';

  @override
  String get loginPasswordRequired => 'Password is required';

  @override
  String get loginForgotPassword => 'Forgot password?';

  @override
  String get loginSubmit => 'Login';

  @override
  String get loginNoAccountQuestion => 'Don\'t have an account? ';

  @override
  String get loginSignUpCta => 'Sign Up';

  @override
  String get loginResetPasswordTitle => 'Reset password';

  @override
  String get loginResetPasswordBody =>
      'Enter the email linked to your account. We will send a reset link if an account exists.';

  @override
  String get loginResetEmailRequired =>
      'Please enter the email tied to your account.';

  @override
  String get loginResetSendError =>
      'Unable to send reset email. Please try again.';

  @override
  String get loginResetSendLink => 'Send link';

  @override
  String loginResetLinkSent(Object email) {
    return 'If an account exists for $email, a reset link is on the way.';
  }

  @override
  String get appTagline => 'Field Observation System';

  @override
  String observerWelcomeBack(Object firstName) {
    return 'Welcome back, $firstName!';
  }

  @override
  String get observerSelectProjectPrompt =>
      'Select a project to begin your observation';

  @override
  String get profileLoggedInAs => 'Logged in as';

  @override
  String get profileMenuProfileSettings => 'Profile & Settings';

  @override
  String get profileMenuNotifications => 'Notifications';

  @override
  String get profileMenuAdminPanel => 'Admin Panel';

  @override
  String get profileMenuProjectMap => 'Project Map';

  @override
  String get profileMenuProjects => 'Projects';

  @override
  String get profileMenuObserver => 'Observer';

  @override
  String get projectsNeedHelp =>
      'Need help? Contact your administrator for support';

  @override
  String get signupTitle => 'Create Account';

  @override
  String get signupFirstNameLabel => 'First Name';

  @override
  String get signupFirstNamePlaceholder => 'Enter your first name';

  @override
  String get signupLastNameLabel => 'Last Name';

  @override
  String get signupLastNamePlaceholder => 'Enter your last name';

  @override
  String get signupEmailLabel => 'Email';

  @override
  String get signupEmailPlaceholder => 'your.email@example.com';

  @override
  String get signupEmailRequired => 'Email is required';

  @override
  String get signupEmailInvalid => 'Please enter a valid email';

  @override
  String get signupPasswordLabel => 'Password';

  @override
  String get signupPasswordPlaceholder => 'Create a password';

  @override
  String get signupPasswordRequired => 'Password is required';

  @override
  String get signupPasswordTooShort => 'Password must be at least 6 characters';

  @override
  String get signupPasswordConfirmLabel => 'Confirm Password';

  @override
  String get signupPasswordConfirmPlaceholder => 'Re-enter your password';

  @override
  String get signupPasswordConfirmRequired => 'Please confirm your password';

  @override
  String get signupSubmit => 'Create Account';

  @override
  String get signupRoleInfoPrefix => 'New accounts are assigned the ';

  @override
  String get signupRoleName => 'Observer role';

  @override
  String get signupRoleInfoSuffix =>
      ' by default. Admin privileges must be granted by the database owner.';

  @override
  String get signupAlreadyHaveAccountPrefix => 'Already have an account? ';

  @override
  String get signupLoginCta => 'Login';

  @override
  String get observerSummaryTitle => 'Session Summary';

  @override
  String get observerSummaryEmptyTitle => 'No observations recorded';

  @override
  String get observerSummaryEmptySubtitle =>
      'No observations this session. Submit to return to your projects.';

  @override
  String get observerSummaryTotalRecorded => 'Total Recorded';

  @override
  String observerSummaryEntries(int count) {
    return '$count entries';
  }

  @override
  String get observerSummaryIndividuals => 'Individuals';

  @override
  String get observerSummaryGroups => 'Groups';

  @override
  String get observerSummaryGroupObservations => 'Group Observations';

  @override
  String get observerSummaryDemographics => 'Demographics';

  @override
  String get observerSummaryMales => 'Males';

  @override
  String get observerSummaryFemales => 'Females';

  @override
  String get observerSummaryChildren => 'Children';

  @override
  String get observerSummaryActivityLevels => 'Activity Levels';

  @override
  String get observerSummaryActivitySedentary => 'Sedentary';

  @override
  String get observerSummaryActivityMoving => 'Moving';

  @override
  String get observerSummaryActivityIntense => 'Intense';

  @override
  String get observerSummarySessionDetails => 'Session Details';

  @override
  String get observerSummaryLocation => 'Location';

  @override
  String get observerSummaryDate => 'Date';

  @override
  String get observerSummaryTime => 'Time';

  @override
  String get observerSummaryWeather => 'Weather';

  @override
  String get observerSummarySubmit => 'Submit Session';

  @override
  String get weatherCloudy => 'cloudy';

  @override
  String get weatherRainy => 'rainy';

  @override
  String get weatherSunny => 'sunny';

  @override
  String get observerSummaryLocationMultiple => 'Multiple';

  @override
  String get observerSummaryLocationCruyff => 'C - Cruyff Court';

  @override
  String get observerSummaryLocationBasketball => 'B - Basketball Field';

  @override
  String get observerSummaryLocationGrass => 'G - Grass Field';

  @override
  String get observerSummaryLocationCustom => 'Custom';

  @override
  String get observerFinishSession => 'Finish Session';

  @override
  String get observerSubmitGroup => 'Submit Group';

  @override
  String get observerSubmitPerson => 'Submit Person';

  @override
  String get observerNoOptionsConfigured => 'No options configured.';

  @override
  String get observerOtherOption => 'Other';

  @override
  String get observerNoProjectTitle => 'No project selected';

  @override
  String get observerNoProjectSubtitle =>
      'Choose a project from the list to start recording observations.';

  @override
  String get observerBackToProjectList => 'Back to projects';

  @override
  String get observerAdditionalNotesHint => 'Additional notes...';

  @override
  String get observerActivityNotesPlaceholder => 'Describe what is happening';

  @override
  String get observerRemarksPlaceholder => 'Any extra remarks?';

  @override
  String get observerDateLabel => 'Date';

  @override
  String get observerTimeLabel => 'Time';

  @override
  String get observerModeLabel => 'Observation Mode';

  @override
  String get observerModeIndividual => 'Individual';

  @override
  String get observerModeGroup => 'Group';

  @override
  String get observerNoFieldsConfigured =>
      'No observation fields are configured for this project.';

  @override
  String get observerSelectProject =>
      'Select a project before recording observations.';

  @override
  String get observerPleaseSignIn => 'Please sign in again to continue.';

  @override
  String get observerEnterNumber => 'Please enter a number';

  @override
  String get observerPleaseSelectOption => 'Please select an option';

  @override
  String get observerSelectGender => 'Select gender';

  @override
  String get observerSelectAge => 'Select age';

  @override
  String get observerGenderDistribution => 'Group Demographics';

  @override
  String get observerGenderDistributionHelper =>
      'Specify gender and age for each person in the group';

  @override
  String get observerAgeDistribution => 'Age Distribution';

  @override
  String get observerAgeDistributionHelper =>
      'How many people in each age range?';

  @override
  String get observerGenderMale => 'Male';

  @override
  String get observerGenderFemale => 'Female';

  @override
  String get observerAge11AndYounger => '11 and younger';

  @override
  String get observerAge12to17 => '12 – 17';

  @override
  String get observerAge18to24 => '18 – 24';

  @override
  String get observerAge25to44 => '25 – 44';

  @override
  String get observerAge45to64 => '45 – 64';

  @override
  String get observerAge65Plus => '65+';

  @override
  String get observerProjectsTitle => 'Your Projects';

  @override
  String observerProjectsAvailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count projects available',
      one: '$count project available',
    );
    return '$_temp0';
  }

  @override
  String get observerProjectsSearchPlaceholder => 'Search projects...';

  @override
  String get observerProjectsEmptySearchTitle => 'No projects found';

  @override
  String get observerProjectsEmptySearchSubtitle =>
      'Try adjusting your search terms';

  @override
  String get observerProjectsEmptyTitle => 'No Projects Assigned';

  @override
  String get observerProjectsEmptySubtitle =>
      'You don\'t have any observation projects assigned yet.\nPlease contact your administrator to get access to projects.';

  @override
  String get observerProjectsRefresh => 'Refresh projects';

  @override
  String get projectMapTitle => 'Project Map';

  @override
  String get observerSuccessTitle => 'Observation Saved!';

  @override
  String observerSuccessPerson(Object personId) {
    return 'Person #$personId has been recorded.';
  }

  @override
  String observerSuccessGroup(int groupSize) {
    return 'Group of $groupSize people has been recorded.';
  }

  @override
  String get observerSuccessPreparing => 'Preparing next observation...';

  @override
  String get exportSheetName => 'Observations';

  @override
  String get exportProjectLabel => 'Project';

  @override
  String get exportLocationLabel => 'Location';

  @override
  String get exportLocationNotSet => 'Not set';

  @override
  String get exportExportedAt => 'Exported At';

  @override
  String get exportObservationCount => 'Observation Count';

  @override
  String get exportHeaderPersonId => 'Person ID';

  @override
  String get exportHeaderMode => 'Mode';

  @override
  String get exportHeaderTimestamp => 'Timestamp';

  @override
  String get exportHeaderObserverEmail => 'Observer Email';

  @override
  String get exportHeaderObserverUid => 'Observer UID';

  @override
  String get exportHeaderGender => 'Gender';

  @override
  String get exportHeaderAgeGroup => 'Age Group';

  @override
  String get exportHeaderSocialContext => 'Social Context';

  @override
  String get exportHeaderActivityLevel => 'Activity Level';

  @override
  String get exportHeaderActivityType => 'Activity Type';

  @override
  String get exportHeaderLocation => 'Location';

  @override
  String get exportHeaderLocationTypeId => 'Location Type ID';

  @override
  String get exportHeaderGroupSize => 'Group Size';

  @override
  String get exportHeaderGenderMix => 'Gender Mix';

  @override
  String get exportHeaderAgeMix => 'Age Mix';

  @override
  String get exportHeaderNotes => 'Notes';

  @override
  String get exportSuccessMessage => 'Excel export saved to your device.';

  @override
  String get exportErrorMessage => 'Unable to export observations right now.';

  @override
  String get commonClose => 'Close';

  @override
  String get projectMapLocationUnavailable => 'Location unavailable';

  @override
  String get projectMapOpenInAdmin => 'Open in Admin';

  @override
  String get projectMapNoMappableProjects =>
      'No projects with mappable locations yet.';

  @override
  String projectMapProjectCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count projects',
      one: '$count project',
    );
    return '$_temp0';
  }

  @override
  String get projectMapLegendTitle => 'Legend';

  @override
  String get projectMapLegendActive => 'Active projects';

  @override
  String get projectMapLegendFinished => 'Finished projects';

  @override
  String get projectMapLegendArchived => 'Archived projects';

  @override
  String get projectsLoading => 'Loading projects...';

  @override
  String get projectsLoadErrorTitle => 'Couldn\'t load projects';

  @override
  String get projectsRefreshTooltip => 'Refresh projects';

  @override
  String get adminStatusActive => 'Active';

  @override
  String get adminStatusFinished => 'Finished';

  @override
  String get adminStatusArchived => 'Archived';

  @override
  String get adminSectionGeneral => 'General';

  @override
  String get adminSectionObservers => 'Observers';

  @override
  String get adminSectionFields => 'Fields';

  @override
  String get adminSectionData => 'Data';

  @override
  String get adminManageProjectsTitle => 'Manage Projects';

  @override
  String get adminManageProjectsSubtitle =>
      'Create and organize observation projects, assign observers, and monitor data collection';

  @override
  String get adminCreateNewProject => 'Create New Project';

  @override
  String adminNoProjectsTitle(Object status) {
    return 'No $status projects yet';
  }

  @override
  String get adminNoProjectsSubtitle =>
      'Create your first project to get started';

  @override
  String adminStatusChipLabel(Object status, int count) {
    return '$status ($count)';
  }

  @override
  String get adminProjectCreatedSuccess => 'Project created successfully!';

  @override
  String adminStatusProjectsTitle(Object status, int count) {
    return '$status Projects ($count)';
  }

  @override
  String get adminNewProjectNameLabel => 'Project Name';

  @override
  String get adminNewProjectNameHint => 'e.g., Parkstraat Observation Site';

  @override
  String get adminNewProjectMainLocationLabel => 'Main Location';

  @override
  String get adminNewProjectMainLocationHint => 'e.g., Parkstraat, Amsterdam';

  @override
  String get adminNoSuggestionsFound => 'No suggestions found';

  @override
  String get adminDescriptionOptionalLabel => 'Description (Optional)';

  @override
  String get adminDescriptionOptionalHint =>
      'Add project description or notes...';

  @override
  String get adminCreating => 'Creating...';

  @override
  String get adminCreateProject => 'Create Project';

  @override
  String get adminLocationTypesTitle => 'Location Types';

  @override
  String get adminLocationTypesSubtitle =>
      'Select all location types available at this site';

  @override
  String get adminCustomLocationPlaceholder =>
      'Add a custom location... (Enter or Add)';

  @override
  String get adminAdd => 'Add';

  @override
  String get adminHiddenLocationTypes => 'Hidden location types:';

  @override
  String get adminAssignObserversTitle => 'Assign Observers (Optional)';

  @override
  String get adminAssignObserversSubtitle =>
      'Add team members who can collect observations for this project';

  @override
  String get adminAddObserver => 'Add Observer';

  @override
  String get adminSearchObserversPlaceholder =>
      'Search observers by name or email...';

  @override
  String get adminNoObserversFound => 'No observers found';

  @override
  String get adminDone => 'Done';

  @override
  String get adminNoObserversAssigned =>
      'No observers assigned yet. You can add them later.';

  @override
  String get adminProjectMainLocationUnset => 'Main location not set';

  @override
  String get adminMainLocationTitle => 'Main Location';

  @override
  String get adminMainLocationDescription =>
      'Specify the main site this project covers. Individual location types below should describe areas inside this location.';

  @override
  String get adminMainLocationHint => 'e.g., Parkstraat, Amsterdam Noord';

  @override
  String get adminMainLocationSave => 'Save Changes';

  @override
  String get adminMainLocationSaving => 'Saving...';

  @override
  String adminProjectObservationCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count observations',
      one: '$count observation',
    );
    return '$_temp0';
  }

  @override
  String adminProjectObserverCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count observers',
      one: '$count observer',
    );
    return '$_temp0';
  }

  @override
  String get adminDeleteWarningTitle =>
      'You are about to permanently delete this project. This will remove:';

  @override
  String adminDeleteRemoveObservations(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count observations',
      one: '$count observation',
    );
    return '• $_temp0';
  }

  @override
  String get adminDeleteRemoveObservers => '• All assigned observers';

  @override
  String get adminDeleteRemoveData => '• All project data and settings';

  @override
  String get adminDeleteIrreversible =>
      'This data cannot be recovered once deleted.';

  @override
  String get adminDeleteConfirmQuestion =>
      'Are you absolutely sure you want to continue?';

  @override
  String get adminDeleteConfirmButton => 'Yes, Delete Project';

  @override
  String get adminDeleteDialogTitle => 'Delete Project?';

  @override
  String get adminDeleteWarningHeader =>
      '⚠️ WARNING: This action cannot be reversed!';

  @override
  String get adminLoadingProjects => 'Loading projects...';

  @override
  String get adminChangeStatusTooltip => 'Change project status';

  @override
  String adminStatusOptionCurrent(Object status) {
    return '$status (current)';
  }

  @override
  String adminObserverAssignedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count observers assigned',
      one: '$count observer assigned',
    );
    return '$_temp0';
  }

  @override
  String get adminLocationTypesHeader => 'Location Types';

  @override
  String get adminAddLocation => 'Add Location';

  @override
  String get adminAddLocationHint => 'Add location';

  @override
  String get adminNoLocationTypes => 'No location types configured';

  @override
  String get adminAssignedObservers => 'Assigned Observers';

  @override
  String get adminObserverSearchPlaceholder =>
      'Search observers by name or email...';

  @override
  String get adminObserversAllAssigned => 'All observers are already assigned';

  @override
  String get adminNoObserversFoundSelector => 'No observers found';

  @override
  String get adminNoObserversAssignedTitle => 'No observers assigned yet';

  @override
  String get adminNoObserversAssignedSubtitle =>
      'Click \"Add Observer\" to assign team members';

  @override
  String get adminClearAll => 'Clear All';

  @override
  String get adminEdit => 'Edit';

  @override
  String get adminEntriesLabel => 'Entries';

  @override
  String adminEntriesOption(Object count) {
    return '$count entries';
  }

  @override
  String get adminNoFieldsTitle => 'No fields configured yet.';

  @override
  String get adminNoFieldsSubtitle =>
      'Add your first custom field or restore the default template.';

  @override
  String get adminUnsavedFieldsTitle => 'Unsaved field changes';

  @override
  String get adminUnsavedFieldsSubtitle =>
      'You made edits that are not saved yet.';

  @override
  String get adminUnsavedFieldsDialogBody =>
      'Save your changes before leaving this page or discard them.';

  @override
  String get adminDiscardChanges => 'Discard changes';

  @override
  String get adminFieldStandard => 'Standard';

  @override
  String get adminFieldCustom => 'Custom';

  @override
  String get adminEditObservationTitle => 'Edit Observation';

  @override
  String get adminPersonIdLabel => 'Person ID';

  @override
  String get adminPersonIdHint => 'Enter person ID';

  @override
  String get adminAgeGroupLabel => 'Age Group';

  @override
  String get adminSocialContextLabel => 'Social Context';

  @override
  String get adminActivityLevelLabel => 'Activity Level';

  @override
  String get adminActivityTypeLabel => 'Activity Type';

  @override
  String get adminGenderMale => 'Male';

  @override
  String get adminGenderFemale => 'Female';

  @override
  String get adminAgeChild => 'Child';

  @override
  String get adminAgeTeen => 'Teen';

  @override
  String get adminAgeAdult => 'Adult';

  @override
  String get adminAgeSenior => 'Senior';

  @override
  String get adminSocialAlone => 'Alone';

  @override
  String get adminSocialTogether => 'Together';

  @override
  String get adminActivityLevelSitting => 'Sitting';

  @override
  String get adminActivityLevelMoving => 'Moving';

  @override
  String get adminActivityLevelIntense => 'Intense';

  @override
  String get adminActivityTypeOrganized => 'Organized';

  @override
  String get adminActivityTypeUnorganized => 'Unorganized';

  @override
  String get adminEditStandardField => 'Edit Standard Field';

  @override
  String get adminEditCustomField => 'Edit Custom Field';

  @override
  String get adminFieldLabel => 'Label';

  @override
  String get adminHelperTextOptional => 'Helper text (optional)';

  @override
  String get adminTextFieldSettings => 'Text field settings';

  @override
  String get adminPlaceholderLabel => 'Placeholder';

  @override
  String get adminMaxLengthOptional => 'Max length (optional)';

  @override
  String get adminAllowMultilineInput => 'Allow multiline input';

  @override
  String get adminOptionsTitle => 'Options';

  @override
  String get adminAddOption => 'Add option';

  @override
  String get adminRemoveOption => 'Remove option';

  @override
  String get adminAllowMultipleValues => 'Allow selecting multiple values';

  @override
  String get adminAudienceIndividual => 'Individual';

  @override
  String get adminAudienceGroup => 'Group';

  @override
  String get adminAudienceBoth => 'Both';

  @override
  String adminOptionNumber(int index) {
    return 'Option $index';
  }

  @override
  String get adminOptionFallback => 'Option';

  @override
  String get adminFieldLabelRequiredError => 'Field label is required.';

  @override
  String get adminOptionMinimumError => 'Please provide at least two options.';

  @override
  String get adminFieldTypeTextInput => 'Text input';

  @override
  String get adminFieldTypeNumber => 'Number';

  @override
  String get adminFieldTypeDropdownLegacy => 'Dropdown (legacy)';

  @override
  String get adminFieldTypeMultiSelect => 'Multi-select';

  @override
  String get adminFieldTypeCheckbox => 'Checkbox';

  @override
  String get adminFieldTypeDate => 'Date';

  @override
  String get adminFieldTypeTime => 'Time';

  @override
  String get adminFieldTypeRating => 'Rating scale';

  @override
  String adminObservationsRecorded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count observations recorded',
      one: '$count observation recorded',
    );
    return '$_temp0';
  }

  @override
  String get adminPanelTitle => 'Admin Panel';

  @override
  String get adminAdjustStatus => 'Adjust status';

  @override
  String get adminUpdatingStatus => 'Updating...';

  @override
  String get adminObservationFieldsTitle => 'Observation Fields';

  @override
  String adminObservationFieldsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fields',
      one: '$count field',
    );
    return '$_temp0';
  }

  @override
  String get adminObservationFieldsSubtitle =>
      'Reorder, edit, or toggle standard/custom fields. Remember to save changes.';

  @override
  String get adminAddField => 'Add Field';

  @override
  String get adminRestoreDefaults => 'Restore defaults';

  @override
  String get adminSaving => 'Saving…';

  @override
  String get adminSaveChanges => 'Save Changes';

  @override
  String get adminDeleteFieldTitle => 'Delete field';

  @override
  String adminDeleteFieldMessage(Object label) {
    return 'Are you sure you want to delete \"$label\"? This cannot be undone.';
  }

  @override
  String get adminAdditionalNotesHint => 'Additional notes...';

  @override
  String get adminRequiredField => 'Required field';

  @override
  String get adminRequiredFieldSubtitle =>
      'Observers must provide a value before saving.';

  @override
  String get adminFieldTypeLabel => 'Field type';

  @override
  String get adminFormVisibility => 'Form visibility';

  @override
  String get adminObservationDataTitle => 'Observation Data';

  @override
  String get adminExporting => 'Exporting...';

  @override
  String get adminExport => 'Export';

  @override
  String get adminFiltersTitle => 'Filters';

  @override
  String get adminRefreshData => 'Refresh data';

  @override
  String get adminFilterGender => 'Gender';

  @override
  String get adminFilterAge => 'Age';

  @override
  String get adminFilterSocial => 'Social';

  @override
  String get adminFilterLevel => 'Level';

  @override
  String get adminFilterLocation => 'Location';

  @override
  String get adminNoObservationDataTitle => 'No observation data yet';

  @override
  String get adminNoObservationDataSubtitle =>
      'Data will appear here once observers start collecting';

  @override
  String get adminNoFilteredObservationsTitle =>
      'No observations match your filters';

  @override
  String get adminNoFilteredObservationsSubtitle =>
      'Try adjusting your filter criteria';

  @override
  String get adminLoadingMore => 'Loading more...';

  @override
  String get adminLoadOlderObservations => 'Load older observations';

  @override
  String get adminRecordGroup => 'Group';

  @override
  String get adminRecordIndividual => 'Individual';

  @override
  String get adminFieldGender => 'Gender';

  @override
  String get adminFieldAge => 'Age';

  @override
  String get adminFieldSocial => 'Social';

  @override
  String get adminFieldGroupSize => 'Group Size';

  @override
  String get adminFieldGenderMix => 'Gender Mix';

  @override
  String get adminFieldAgeMix => 'Age Mix';

  @override
  String get adminFieldActivity => 'Activity';

  @override
  String get adminFieldType => 'Type';

  @override
  String get adminFieldLocation => 'Location';

  @override
  String get adminFieldEmail => 'Email:';

  @override
  String get adminFieldNotes => 'Notes';

  @override
  String get adminGroupSizeLockedNote =>
      'Group size is always required for group observations and cannot be disabled.';

  @override
  String get adminGroupSizeRequiredToggleNote =>
      'Required is fixed on for this field.';

  @override
  String get adminDemographicFieldTitle => 'Group demographics';

  @override
  String get adminDemographicFieldDescription =>
      'This field records pairs of gender and age for each person in the group.';

  @override
  String get adminDemographicFixedGenders =>
      'Genders are fixed and cannot be changed:';

  @override
  String get adminDemographicAgeNote =>
      'Each selected gender must be paired with an age group when observers fill in the form.';

  @override
  String get adminDemographicLockedConfig =>
      'Options are locked because this field uses the combined gender + age matrix in the observer app.';

  @override
  String get adminNoRecordsCollected => 'No records collected yet';

  @override
  String adminFilteredResults(int count) {
    return 'Filtered results (showing $count)';
  }

  @override
  String adminShowingLatest(int visible, int total) {
    return 'Showing latest $visible of $total records';
  }
}
