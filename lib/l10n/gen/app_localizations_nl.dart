// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appTitle => 'InnoBeweegLab - Field Observation System';

  @override
  String get languageEnglish => 'Engels';

  @override
  String get languageDutch => 'Nederlands';

  @override
  String get profileReauthRequired =>
      'Log opnieuw in om je naam bij te werken.';

  @override
  String get profileNameEmptyError => 'Naam mag niet leeg zijn.';

  @override
  String get profileNothingToUpdate => 'Niets om bij te werken.';

  @override
  String get profileNameUpdated => 'Naam bijgewerkt.';

  @override
  String get profileUpdateNameError => 'Naam kan nu niet worden bijgewerkt.';

  @override
  String get profileNoEmailError =>
      'Geen e-mailadres gekoppeld aan dit account.';

  @override
  String profileResetLinkSent(Object email) {
    return 'Als er een account bestaat voor $email, sturen we een resetlink.';
  }

  @override
  String get profileResetFailed => 'Kon reset-e-mail niet versturen.';

  @override
  String get profileLogoutError =>
      'Uitloggen lukt nu niet. Probeer het opnieuw.';

  @override
  String get profileSettingsTitle => 'Profiel & instellingen';

  @override
  String get profileSectionTitle => 'Profiel';

  @override
  String get profileNameLabel => 'Naam';

  @override
  String get profileNameHint => 'Je naam';

  @override
  String get profileSaveName => 'Naam opslaan';

  @override
  String get profileEmailLabel => 'E-mail';

  @override
  String get profileUnavailable => 'Niet beschikbaar';

  @override
  String get profileRoleLabel => 'Rol';

  @override
  String get profileRoleAdmin => 'Admin';

  @override
  String get profileRoleObserver => 'Observator';

  @override
  String get profileRoleUnknown => 'Onbekende rol';

  @override
  String get profilePreferencesTitle => 'Voorkeuren';

  @override
  String get profileLanguagePreference => 'Taalvoorkeur';

  @override
  String get profileSecurityTitle => 'Beveiliging';

  @override
  String get profileSendingReset => 'Reset versturen...';

  @override
  String get profileChangePassword => 'Wachtwoord wijzigen';

  @override
  String get profileLogout => 'Uitloggen';

  @override
  String get profileShortcutsTitle => 'Snelkoppelingen';

  @override
  String get profileOpenAdminPanel => 'Open adminpaneel';

  @override
  String get profileAdminPanelSubtitle =>
      'Beheer projecten, observatoren en meldingen';

  @override
  String get adminNotificationsTitle => 'Beheermeldingen';

  @override
  String get notificationsNavTitle => 'Meldingen';

  @override
  String get notificationsRecentActivity => 'Recente activiteit';

  @override
  String get notificationsMarkAllRead => 'Alles als gelezen markeren';

  @override
  String get notificationsMarkAllReadSuccess =>
      'Alle meldingen gemarkeerd als gelezen.';

  @override
  String get notificationsMarkAllReadFailure =>
      'Kon meldingen niet als gelezen markeren.';

  @override
  String get notificationsLoadError =>
      'Meldingen kunnen nu niet worden geladen.';

  @override
  String get notificationsEmptyTitle => 'Nog geen meldingen';

  @override
  String get notificationsEmptySubtitle =>
      'Nieuwe gebruikersmeldingen verschijnen hier zodra ze binnenkomen.';

  @override
  String get relativeJustNow => 'Zojuist';

  @override
  String relativeMinutesAgo(int minutes) {
    return '$minutes min geleden';
  }

  @override
  String relativeHoursAgo(int hours) {
    return '$hours u geleden';
  }

  @override
  String get commonRefresh => 'Vernieuwen';

  @override
  String get commonCancel => 'Annuleren';

  @override
  String get commonDelete => 'Verwijderen';

  @override
  String get commonSaveChanges => 'Wijzigingen opslaan';

  @override
  String get commonDone => 'Klaar';

  @override
  String get commonBackToProjects => 'Terug naar projecten';

  @override
  String get commonTryAgain => 'Probeer opnieuw';

  @override
  String get commonEmailLabel => 'E-mail';

  @override
  String get commonPasswordLabel => 'Wachtwoord';

  @override
  String get authCheckingSession => 'Sessie controleren...';

  @override
  String get authRestoringWorkspace => 'Werkruimte herstellen...';

  @override
  String get authRestoreError =>
      'Profiel kan niet worden hersteld. Log opnieuw in.';

  @override
  String get authReturnToLogin => 'Terug naar login';

  @override
  String get loginTitle => 'Inloggen';

  @override
  String get loginErrorGeneric => 'Inloggen lukt nu niet. Probeer het opnieuw.';

  @override
  String get loginEmailPlaceholder => 'jouw.email@voorbeeld.com';

  @override
  String get loginEmailRequired => 'E-mail is verplicht';

  @override
  String get loginEmailInvalid => 'Voer een geldig e-mailadres in';

  @override
  String get loginPasswordPlaceholder => 'Voer je wachtwoord in';

  @override
  String get loginPasswordRequired => 'Wachtwoord is verplicht';

  @override
  String get loginForgotPassword => 'Wachtwoord vergeten?';

  @override
  String get loginSubmit => 'Inloggen';

  @override
  String get loginNoAccountQuestion => 'Nog geen account? ';

  @override
  String get loginSignUpCta => 'Aanmelden';

  @override
  String get loginResetPasswordTitle => 'Wachtwoord resetten';

  @override
  String get loginResetPasswordBody =>
      'Vul het e-mailadres in dat aan je account is gekoppeld. We sturen een resetlink als er een account bestaat.';

  @override
  String get loginResetEmailRequired =>
      'Vul het e-mailadres van je account in.';

  @override
  String get loginResetSendError =>
      'Reset-e-mail versturen lukt niet. Probeer het opnieuw.';

  @override
  String get loginResetSendLink => 'Link versturen';

  @override
  String loginResetLinkSent(Object email) {
    return 'Als er een account bestaat voor $email, sturen we een resetlink.';
  }

  @override
  String get appTagline => 'Veldobservatiesysteem';

  @override
  String observerWelcomeBack(Object firstName) {
    return 'Welkom terug, $firstName!';
  }

  @override
  String get observerSelectProjectPrompt =>
      'Selecteer een project om je observatie te starten';

  @override
  String get profileLoggedInAs => 'Ingelogd als';

  @override
  String get profileMenuProfileSettings => 'Profiel & instellingen';

  @override
  String get profileMenuNotifications => 'Meldingen';

  @override
  String get profileMenuAdminPanel => 'Beheerpaneel';

  @override
  String get profileMenuProjectMap => 'Projectkaart';

  @override
  String get profileMenuProjects => 'Projecten';

  @override
  String get profileMenuObserver => 'Observer';

  @override
  String get projectsNeedHelp =>
      'Hulp nodig? Neem contact op met je beheerder voor ondersteuning';

  @override
  String get signupTitle => 'Account aanmaken';

  @override
  String get signupFirstNameLabel => 'Voornaam';

  @override
  String get signupFirstNamePlaceholder => 'Vul je voornaam in';

  @override
  String get signupLastNameLabel => 'Achternaam';

  @override
  String get signupLastNamePlaceholder => 'Vul je achternaam in';

  @override
  String get signupEmailLabel => 'E-mail';

  @override
  String get signupEmailPlaceholder => 'jouw.email@example.com';

  @override
  String get signupEmailRequired => 'E-mail is verplicht';

  @override
  String get signupEmailInvalid => 'Vul een geldig e-mailadres in';

  @override
  String get signupPasswordLabel => 'Wachtwoord';

  @override
  String get signupPasswordPlaceholder => 'Kies een wachtwoord';

  @override
  String get signupPasswordRequired => 'Wachtwoord is verplicht';

  @override
  String get signupPasswordTooShort =>
      'Wachtwoord moet minstens 6 tekens hebben';

  @override
  String get signupPasswordConfirmLabel => 'Bevestig wachtwoord';

  @override
  String get signupPasswordConfirmPlaceholder =>
      'Voer je wachtwoord opnieuw in';

  @override
  String get signupPasswordConfirmRequired => 'Bevestig je wachtwoord';

  @override
  String get signupSubmit => 'Account aanmaken';

  @override
  String get signupRoleInfoPrefix => 'Nieuwe accounts krijgen standaard de ';

  @override
  String get signupRoleName => 'Observer-rol';

  @override
  String get signupRoleInfoSuffix =>
      ' toegewezen. Adminrechten moeten worden verstrekt door de database-eigenaar.';

  @override
  String get signupAlreadyHaveAccountPrefix => 'Al een account? ';

  @override
  String get signupLoginCta => 'Inloggen';

  @override
  String get observerSummaryTitle => 'Sessiesamenvatting';

  @override
  String get observerSummaryEmptyTitle => 'Geen observaties vastgelegd';

  @override
  String get observerSummaryEmptySubtitle =>
      'Noteer minimaal één persoon of groep voordat je een sessie indient.';

  @override
  String get observerSummaryTotalRecorded => 'Totaal vastgelegd';

  @override
  String observerSummaryEntries(int count) {
    return '$count registraties';
  }

  @override
  String get observerSummaryIndividuals => 'Individuen';

  @override
  String get observerSummaryGroups => 'Groepen';

  @override
  String get observerSummaryGroupObservations => 'Groepsobservaties';

  @override
  String get observerSummaryDemographics => 'Demografie';

  @override
  String get observerSummaryMales => 'Mannen';

  @override
  String get observerSummaryFemales => 'Vrouwen';

  @override
  String get observerSummaryChildren => 'Kinderen';

  @override
  String get observerSummaryActivityLevels => 'Activiteitsniveaus';

  @override
  String get observerSummaryActivitySedentary => 'Zittend';

  @override
  String get observerSummaryActivityMoving => 'Bewegend';

  @override
  String get observerSummaryActivityIntense => 'Intensief';

  @override
  String get observerSummarySessionDetails => 'Sessiedetails';

  @override
  String get observerSummaryLocation => 'Locatie';

  @override
  String get observerSummaryDate => 'Datum';

  @override
  String get observerSummaryTime => 'Tijd';

  @override
  String get observerSummaryWeather => 'Weer';

  @override
  String get observerSummarySubmit => 'Sessie indienen';

  @override
  String get weatherCloudy => 'bewolkt';

  @override
  String get weatherRainy => 'regenachtig';

  @override
  String get weatherSunny => 'zonnig';

  @override
  String get observerSummaryLocationMultiple => 'Meerdere';

  @override
  String get observerSummaryLocationCruyff => 'C - Cruyff Court';

  @override
  String get observerSummaryLocationBasketball => 'B - Basketbalveld';

  @override
  String get observerSummaryLocationGrass => 'G - Grasveld';

  @override
  String get observerSummaryLocationCustom => 'Aangepast';

  @override
  String get observerFinishSession => 'Sessie afronden';

  @override
  String get observerSubmitGroup => 'Groep indienen';

  @override
  String get observerSubmitPerson => 'Persoon indienen';

  @override
  String get observerNoOptionsConfigured => 'Geen opties geconfigureerd.';

  @override
  String get observerOtherOption => 'Anders';

  @override
  String get observerNoProjectTitle => 'Geen project geselecteerd';

  @override
  String get observerNoProjectSubtitle =>
      'Kies een project uit de lijst om observaties te starten.';

  @override
  String get observerBackToProjectList => 'Terug naar projecten';

  @override
  String get observerAdditionalNotesHint => 'Extra notities...';

  @override
  String get observerDateLabel => 'Datum';

  @override
  String get observerTimeLabel => 'Tijd';

  @override
  String get observerModeLabel => 'Observatiemodus';

  @override
  String get observerModeIndividual => 'Individu';

  @override
  String get observerModeGroup => 'Groep';

  @override
  String get observerNoFieldsConfigured =>
      'Er zijn geen observatievelden voor dit project geconfigureerd.';

  @override
  String get observerSelectProject =>
      'Kies eerst een project voordat je observaties registreert.';

  @override
  String get observerPleaseSignIn => 'Meld je opnieuw aan om door te gaan.';

  @override
  String get observerEnterNumber => 'Vul een getal in';

  @override
  String get observerProjectsTitle => 'Jouw projecten';

  @override
  String observerProjectsAvailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count projecten beschikbaar',
      one: '$count project beschikbaar',
    );
    return '$_temp0';
  }

  @override
  String get observerProjectsSearchPlaceholder => 'Zoek projecten...';

  @override
  String get observerProjectsEmptySearchTitle => 'Geen projecten gevonden';

  @override
  String get observerProjectsEmptySearchSubtitle => 'Pas je zoektermen aan';

  @override
  String get observerProjectsEmptyTitle => 'Geen projecten toegewezen';

  @override
  String get observerProjectsEmptySubtitle =>
      'Je hebt nog geen observatieprojecten toegewezen.\nNeem contact op met je beheerder voor toegang.';

  @override
  String get observerProjectsRefresh => 'Projecten vernieuwen';

  @override
  String get projectMapTitle => 'Projectkaart';

  @override
  String get observerSuccessTitle => 'Observatie opgeslagen!';

  @override
  String observerSuccessPerson(Object personId) {
    return 'Persoon #$personId is geregistreerd.';
  }

  @override
  String observerSuccessGroup(int groupSize) {
    return 'Groep van $groupSize personen is geregistreerd.';
  }

  @override
  String get observerSuccessPreparing => 'Volgende observatie voorbereiden...';

  @override
  String get exportSheetName => 'Observaties';

  @override
  String get exportProjectLabel => 'Project';

  @override
  String get exportLocationLabel => 'Locatie';

  @override
  String get exportLocationNotSet => 'Niet ingesteld';

  @override
  String get exportExportedAt => 'Geëxporteerd op';

  @override
  String get exportObservationCount => 'Aantal observaties';

  @override
  String get exportHeaderPersonId => 'Persoon ID';

  @override
  String get exportHeaderMode => 'Modus';

  @override
  String get exportHeaderTimestamp => 'Tijdstempel';

  @override
  String get exportHeaderObserverEmail => 'Observer e-mail';

  @override
  String get exportHeaderObserverUid => 'Observer UID';

  @override
  String get exportHeaderGender => 'Geslacht';

  @override
  String get exportHeaderAgeGroup => 'Leeftijdsgroep';

  @override
  String get exportHeaderSocialContext => 'Sociale context';

  @override
  String get exportHeaderActivityLevel => 'Activiteitsniveau';

  @override
  String get exportHeaderActivityType => 'Activiteitstype';

  @override
  String get exportHeaderLocation => 'Locatie';

  @override
  String get exportHeaderLocationTypeId => 'Locatietype-ID';

  @override
  String get exportHeaderGroupSize => 'Groepsgrootte';

  @override
  String get exportHeaderGenderMix => 'Geslachtsverdeling';

  @override
  String get exportHeaderAgeMix => 'Leeftijdsverdeling';

  @override
  String get exportHeaderNotes => 'Notities';

  @override
  String get exportSuccessMessage => 'Excel-export opgeslagen op je apparaat.';

  @override
  String get exportErrorMessage =>
      'Observaties kunnen nu niet worden geëxporteerd.';

  @override
  String get commonClose => 'Sluiten';

  @override
  String get projectMapLocationUnavailable => 'Locatie niet beschikbaar';

  @override
  String get projectMapOpenInAdmin => 'Openen in admin';

  @override
  String projectMapProjectCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count projecten',
      one: '$count project',
    );
    return '$_temp0';
  }

  @override
  String get projectsLoading => 'Projecten laden...';

  @override
  String get projectsLoadErrorTitle => 'Projecten konden niet worden geladen';

  @override
  String get projectsRefreshTooltip => 'Projecten verversen';

  @override
  String get adminStatusActive => 'Actief';

  @override
  String get adminStatusFinished => 'Afgerond';

  @override
  String get adminStatusArchived => 'Gearchiveerd';

  @override
  String get adminSectionGeneral => 'Algemeen';

  @override
  String get adminSectionObservers => 'Observatoren';

  @override
  String get adminSectionFields => 'Velden';

  @override
  String get adminSectionData => 'Data';

  @override
  String get adminManageProjectsTitle => 'Projecten beheren';

  @override
  String get adminManageProjectsSubtitle =>
      'Maak en organiseer observatieprojecten, wijs observatoren toe en volg dataverzameling';

  @override
  String get adminCreateNewProject => 'Nieuw project maken';

  @override
  String adminNoProjectsTitle(Object status) {
    return 'Nog geen $status-projecten';
  }

  @override
  String get adminNoProjectsSubtitle => 'Maak je eerste project om te beginnen';

  @override
  String adminStatusChipLabel(Object status, int count) {
    return '$status ($count)';
  }

  @override
  String get adminProjectCreatedSuccess => 'Project succesvol aangemaakt!';

  @override
  String adminStatusProjectsTitle(Object status, int count) {
    return '$status-projecten ($count)';
  }

  @override
  String get adminNewProjectNameLabel => 'Projectnaam';

  @override
  String get adminNewProjectNameHint => 'bijv. Parkstraat observatielocatie';

  @override
  String get adminNewProjectMainLocationLabel => 'Hoofdlocatie';

  @override
  String get adminNewProjectMainLocationHint => 'bijv. Parkstraat, Amsterdam';

  @override
  String get adminNoSuggestionsFound => 'Geen suggesties gevonden';

  @override
  String get adminDescriptionOptionalLabel => 'Beschrijving (optioneel)';

  @override
  String get adminDescriptionOptionalHint =>
      'Voeg een beschrijving of notities toe...';

  @override
  String get adminCreating => 'Bezig met aanmaken...';

  @override
  String get adminCreateProject => 'Project aanmaken';

  @override
  String get adminLocationTypesTitle => 'Locatietypes';

  @override
  String get adminLocationTypesSubtitle =>
      'Selecteer alle locatietypes die hier beschikbaar zijn';

  @override
  String get adminCustomLocationPlaceholder =>
      'Voeg een aangepaste locatie toe... (Enter of Toevoegen)';

  @override
  String get adminAdd => 'Toevoegen';

  @override
  String get adminHiddenLocationTypes => 'Verborgen locatietypes:';

  @override
  String get adminAssignObserversTitle => 'Observatoren toewijzen (optioneel)';

  @override
  String get adminAssignObserversSubtitle =>
      'Voeg teamleden toe die observaties voor dit project kunnen verzamelen';

  @override
  String get adminAddObserver => 'Observator toevoegen';

  @override
  String get adminSearchObserversPlaceholder =>
      'Zoek observatoren op naam of e-mail...';

  @override
  String get adminNoObserversFound => 'Geen observatoren gevonden';

  @override
  String get adminDone => 'Klaar';

  @override
  String get adminNoObserversAssigned =>
      'Nog geen observatoren toegewezen. Je kunt ze later toevoegen.';

  @override
  String get adminProjectMainLocationUnset => 'Hoofdlocatie niet ingesteld';

  @override
  String adminProjectObservationCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count observaties',
      one: '$count observatie',
    );
    return '$_temp0';
  }

  @override
  String adminProjectObserverCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count observatoren',
      one: '$count observator',
    );
    return '$_temp0';
  }

  @override
  String get adminDeleteWarningTitle =>
      'Je staat op het punt dit project definitief te verwijderen. Hiermee verwijder je:';

  @override
  String adminDeleteRemoveObservations(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count observaties',
      one: '$count observatie',
    );
    return '• $_temp0';
  }

  @override
  String get adminDeleteRemoveObservers => '• Alle gekoppelde observatoren';

  @override
  String get adminDeleteRemoveData => '• Alle projectgegevens en instellingen';

  @override
  String get adminDeleteIrreversible =>
      'Deze gegevens kunnen niet worden teruggezet na verwijderen.';

  @override
  String get adminDeleteConfirmQuestion =>
      'Weet je zeker dat je wilt doorgaan?';

  @override
  String get adminDeleteConfirmButton => 'Ja, verwijder project';

  @override
  String get adminDeleteDialogTitle => 'Project verwijderen?';

  @override
  String get adminDeleteWarningHeader =>
      '⚠️ WAARSCHUWING: Deze actie kan niet ongedaan worden gemaakt!';

  @override
  String get adminLoadingProjects => 'Projecten laden...';

  @override
  String get adminChangeStatusTooltip => 'Projectstatus wijzigen';

  @override
  String adminStatusOptionCurrent(Object status) {
    return '$status (huidig)';
  }

  @override
  String adminObserverAssignedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count observatoren toegewezen',
      one: '$count observator toegewezen',
    );
    return '$_temp0';
  }

  @override
  String get adminLocationTypesHeader => 'Locatietypes';

  @override
  String get adminAddLocation => 'Locatie toevoegen';

  @override
  String get adminAddLocationHint => 'Locatie toevoegen';

  @override
  String get adminNoLocationTypes => 'Geen locatietypes geconfigureerd';

  @override
  String get adminAssignedObservers => 'Toegewezen observatoren';

  @override
  String get adminObserverSearchPlaceholder =>
      'Zoek observatoren op naam of e-mail...';

  @override
  String get adminObserversAllAssigned =>
      'Alle observatoren zijn al toegewezen';

  @override
  String get adminNoObserversFoundSelector => 'Geen observatoren gevonden';

  @override
  String get adminNoObserversAssignedTitle =>
      'Nog geen observatoren toegewezen';

  @override
  String get adminNoObserversAssignedSubtitle =>
      'Klik op \"Observator toevoegen\" om teamleden toe te wijzen';

  @override
  String get adminClearAll => 'Alles wissen';

  @override
  String get adminEdit => 'Bewerken';

  @override
  String get adminEntriesLabel => 'Aantal rijen';

  @override
  String adminEntriesOption(Object count) {
    return '$count items';
  }

  @override
  String get adminNoFieldsTitle => 'Nog geen velden geconfigureerd.';

  @override
  String get adminNoFieldsSubtitle =>
      'Voeg je eerste aangepaste veld toe of herstel het standaard sjabloon.';

  @override
  String get adminFieldStandard => 'Standaard';

  @override
  String get adminFieldCustom => 'Aangepast';

  @override
  String get adminEditObservationTitle => 'Observatie bewerken';

  @override
  String get adminPersonIdLabel => 'Persoons-ID';

  @override
  String get adminPersonIdHint => 'Voer persoons-ID in';

  @override
  String get adminAgeGroupLabel => 'Leeftijdsgroep';

  @override
  String get adminSocialContextLabel => 'Sociale context';

  @override
  String get adminActivityLevelLabel => 'Activiteitsniveau';

  @override
  String get adminActivityTypeLabel => 'Activiteitstype';

  @override
  String get adminGenderMale => 'Man';

  @override
  String get adminGenderFemale => 'Vrouw';

  @override
  String get adminAgeChild => 'Kind';

  @override
  String get adminAgeTeen => 'Tiener';

  @override
  String get adminAgeAdult => 'Volwassene';

  @override
  String get adminAgeSenior => 'Senior';

  @override
  String get adminSocialAlone => 'Alleen';

  @override
  String get adminSocialTogether => 'Samen';

  @override
  String get adminActivityLevelSitting => 'Zittend';

  @override
  String get adminActivityLevelMoving => 'Bewegend';

  @override
  String get adminActivityLevelIntense => 'Intensief';

  @override
  String get adminActivityTypeOrganized => 'Georganiseerd';

  @override
  String get adminActivityTypeUnorganized => 'Ongeorganiseerd';

  @override
  String get adminEditStandardField => 'Standaardveld bewerken';

  @override
  String get adminEditCustomField => 'Aangepast veld bewerken';

  @override
  String get adminFieldLabel => 'Label';

  @override
  String get adminHelperTextOptional => 'Hulptekst (optioneel)';

  @override
  String get adminTextFieldSettings => 'Tekstveld-instellingen';

  @override
  String get adminPlaceholderLabel => 'Plaatshouder';

  @override
  String get adminMaxLengthOptional => 'Maximale lengte (optioneel)';

  @override
  String get adminAllowMultilineInput => 'Meerdere regels toestaan';

  @override
  String get adminOptionsTitle => 'Opties';

  @override
  String get adminAddOption => 'Optie toevoegen';

  @override
  String get adminRemoveOption => 'Optie verwijderen';

  @override
  String get adminAllowMultipleValues => 'Meerdere waarden toestaan';

  @override
  String get adminAudienceIndividual => 'Individu';

  @override
  String get adminAudienceGroup => 'Groep';

  @override
  String get adminAudienceBoth => 'Beide';

  @override
  String adminOptionNumber(int index) {
    return 'Optie $index';
  }

  @override
  String get adminOptionFallback => 'Optie';

  @override
  String get adminFieldLabelRequiredError => 'Veldlabel is verplicht.';

  @override
  String get adminOptionMinimumError => 'Geef minimaal twee opties op.';

  @override
  String get adminFieldTypeTextInput => 'Tekstinvoer';

  @override
  String get adminFieldTypeNumber => 'Nummer';

  @override
  String get adminFieldTypeDropdownLegacy => 'Dropdown (verouderd)';

  @override
  String get adminFieldTypeMultiSelect => 'Meervoudige selectie';

  @override
  String get adminFieldTypeCheckbox => 'Selectievakje';

  @override
  String get adminFieldTypeDate => 'Datum';

  @override
  String get adminFieldTypeTime => 'Tijd';

  @override
  String get adminFieldTypeRating => 'Beoordelingsschaal';

  @override
  String adminObservationsRecorded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count observaties vastgelegd',
      one: '$count observatie vastgelegd',
    );
    return '$_temp0';
  }

  @override
  String get adminPanelTitle => 'Beheerpaneel';

  @override
  String get adminAdjustStatus => 'Status aanpassen';

  @override
  String get adminUpdatingStatus => 'Bijwerken...';

  @override
  String get adminObservationFieldsTitle => 'Observatievelden';

  @override
  String adminObservationFieldsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count velden',
      one: '$count veld',
    );
    return '$_temp0';
  }

  @override
  String get adminObservationFieldsSubtitle =>
      'Herschik, bewerk of schakel standaard/aangepaste velden. Vergeet niet op te slaan.';

  @override
  String get adminAddField => 'Veld toevoegen';

  @override
  String get adminRestoreDefaults => 'Standaard herstellen';

  @override
  String get adminSaving => 'Opslaan…';

  @override
  String get adminSaveChanges => 'Wijzigingen opslaan';

  @override
  String get adminDeleteFieldTitle => 'Veld verwijderen';

  @override
  String adminDeleteFieldMessage(Object label) {
    return 'Weet je zeker dat je \"$label\" wilt verwijderen? Dit kan niet ongedaan worden gemaakt.';
  }

  @override
  String get adminAdditionalNotesHint => 'Extra notities...';

  @override
  String get adminRequiredField => 'Verplicht veld';

  @override
  String get adminRequiredFieldSubtitle =>
      'Observatoren moeten een waarde invullen voordat ze opslaan.';

  @override
  String get adminFieldTypeLabel => 'Veldtype';

  @override
  String get adminFormVisibility => 'Formulierzichtbaarheid';

  @override
  String get adminObservationDataTitle => 'Observatiedata';

  @override
  String get adminExporting => 'Bezig met exporteren...';

  @override
  String get adminExport => 'Exporteren';

  @override
  String get adminFiltersTitle => 'Filters';

  @override
  String get adminRefreshData => 'Gegevens verversen';

  @override
  String get adminFilterGender => 'Geslacht';

  @override
  String get adminFilterAge => 'Leeftijd';

  @override
  String get adminFilterSocial => 'Sociaal';

  @override
  String get adminFilterLevel => 'Niveau';

  @override
  String get adminFilterLocation => 'Locatie';

  @override
  String get adminNoObservationDataTitle => 'Nog geen observatiedata';

  @override
  String get adminNoObservationDataSubtitle =>
      'Data verschijnt hier zodra observatoren starten';

  @override
  String get adminNoFilteredObservationsTitle =>
      'Geen observaties matchen je filters';

  @override
  String get adminNoFilteredObservationsSubtitle => 'Pas je filtercriteria aan';

  @override
  String get adminLoadingMore => 'Meer laden...';

  @override
  String get adminLoadOlderObservations => 'Oudere observaties laden';

  @override
  String get adminRecordGroup => 'Groep';

  @override
  String get adminRecordIndividual => 'Individu';

  @override
  String get adminFieldGender => 'Geslacht';

  @override
  String get adminFieldAge => 'Leeftijd';

  @override
  String get adminFieldSocial => 'Sociaal';

  @override
  String get adminFieldGroupSize => 'Grootte van de groep';

  @override
  String get adminFieldGenderMix => 'Geslachtsverdeling';

  @override
  String get adminFieldAgeMix => 'Leeftijdsverdeling';

  @override
  String get adminFieldActivity => 'Activiteit';

  @override
  String get adminFieldType => 'Type';

  @override
  String get adminFieldLocation => 'Locatie';

  @override
  String get adminFieldEmail => 'E-mail:';

  @override
  String get adminFieldNotes => 'Notities';

  @override
  String get adminNoRecordsCollected => 'Nog geen registraties';

  @override
  String adminFilteredResults(int count) {
    return 'Gefilterde resultaten (toont $count)';
  }

  @override
  String adminShowingLatest(int visible, int total) {
    return 'Toont de laatste $visible van $total registraties';
  }
}
