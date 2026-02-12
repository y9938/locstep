import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('ru'),
  ];

  /// No description provided for @graphEditor.
  ///
  /// In en, this message translates to:
  /// **'Graph Editor'**
  String get graphEditor;

  /// No description provided for @nodes.
  ///
  /// In en, this message translates to:
  /// **'Nodes'**
  String get nodes;

  /// No description provided for @nodesList.
  ///
  /// In en, this message translates to:
  /// **'Nodes List'**
  String get nodesList;

  /// No description provided for @connections.
  ///
  /// In en, this message translates to:
  /// **'Connections'**
  String get connections;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @addNode.
  ///
  /// In en, this message translates to:
  /// **'Add Node'**
  String get addNode;

  /// No description provided for @nodeId.
  ///
  /// In en, this message translates to:
  /// **'Node ID'**
  String get nodeId;

  /// No description provided for @nodeName.
  ///
  /// In en, this message translates to:
  /// **'Node Name'**
  String get nodeName;

  /// No description provided for @customAliases.
  ///
  /// In en, this message translates to:
  /// **'Custom Aliases'**
  String get customAliases;

  /// No description provided for @neighbors.
  ///
  /// In en, this message translates to:
  /// **'Neighbors'**
  String get neighbors;

  /// No description provided for @tour3dUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'3D tour links'**
  String get tour3dUrlLabel;

  /// No description provided for @tour3dUrlAddHint.
  ///
  /// In en, this message translates to:
  /// **'Add 3D tour URL…'**
  String get tour3dUrlAddHint;

  /// No description provided for @imageUrlsLabel.
  ///
  /// In en, this message translates to:
  /// **'Photo URLs'**
  String get imageUrlsLabel;

  /// No description provided for @imageUrlAddHint.
  ///
  /// In en, this message translates to:
  /// **'Add photo URL…'**
  String get imageUrlAddHint;

  /// No description provided for @imageUrlsHelp.
  ///
  /// In en, this message translates to:
  /// **'Paste direct link to image file (app downloads and caches it)'**
  String get imageUrlsHelp;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @nodePreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get nodePreview;

  /// No description provided for @open3dTour.
  ///
  /// In en, this message translates to:
  /// **'Open 3D tour'**
  String get open3dTour;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @graphSaved.
  ///
  /// In en, this message translates to:
  /// **'Graph saved'**
  String get graphSaved;

  /// No description provided for @graphExported.
  ///
  /// In en, this message translates to:
  /// **'Graph exported'**
  String get graphExported;

  /// No description provided for @graphImported.
  ///
  /// In en, this message translates to:
  /// **'Graph imported'**
  String get graphImported;

  /// No description provided for @graphCreated.
  ///
  /// In en, this message translates to:
  /// **'Graph created'**
  String get graphCreated;

  /// No description provided for @graphCloned.
  ///
  /// In en, this message translates to:
  /// **'Graph cloned'**
  String get graphCloned;

  /// No description provided for @graphDeleted.
  ///
  /// In en, this message translates to:
  /// **'Graph deleted'**
  String get graphDeleted;

  /// No description provided for @graphRenamed.
  ///
  /// In en, this message translates to:
  /// **'Graph renamed'**
  String get graphRenamed;

  /// No description provided for @exportError.
  ///
  /// In en, this message translates to:
  /// **'Export error'**
  String get exportError;

  /// No description provided for @importError.
  ///
  /// In en, this message translates to:
  /// **'Import error'**
  String get importError;

  /// No description provided for @fillRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Fill all required fields'**
  String get fillRequiredFields;

  /// No description provided for @nodeAdded.
  ///
  /// In en, this message translates to:
  /// **'Node added'**
  String get nodeAdded;

  /// No description provided for @nodeDeleted.
  ///
  /// In en, this message translates to:
  /// **'Node deleted'**
  String get nodeDeleted;

  /// No description provided for @nodeUpdated.
  ///
  /// In en, this message translates to:
  /// **'Node updated'**
  String get nodeUpdated;

  /// No description provided for @nodeExists.
  ///
  /// In en, this message translates to:
  /// **'Node already exists'**
  String get nodeExists;

  /// No description provided for @edgeAdded.
  ///
  /// In en, this message translates to:
  /// **'Connection added'**
  String get edgeAdded;

  /// No description provided for @edgeDeleted.
  ///
  /// In en, this message translates to:
  /// **'Connection deleted'**
  String get edgeDeleted;

  /// No description provided for @saveGraphDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Save Graph'**
  String get saveGraphDialogTitle;

  /// No description provided for @buildRoute.
  ///
  /// In en, this message translates to:
  /// **'Build Route'**
  String get buildRoute;

  /// No description provided for @noRoute.
  ///
  /// In en, this message translates to:
  /// **'No route found'**
  String get noRoute;

  /// No description provided for @nodeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Node not found'**
  String get nodeNotFound;

  /// No description provided for @startNotFound.
  ///
  /// In en, this message translates to:
  /// **'Start point not found'**
  String get startNotFound;

  /// No description provided for @targetNotFound.
  ///
  /// In en, this message translates to:
  /// **'Target not found'**
  String get targetNotFound;

  /// No description provided for @steps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get steps;

  /// No description provided for @youArrived.
  ///
  /// In en, this message translates to:
  /// **'You have arrived'**
  String get youArrived;

  /// No description provided for @goTo.
  ///
  /// In en, this message translates to:
  /// **'Go to'**
  String get goTo;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minutes;

  /// No description provided for @switchGraph.
  ///
  /// In en, this message translates to:
  /// **'Switch graph'**
  String get switchGraph;

  /// No description provided for @manage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manage;

  /// No description provided for @createNew.
  ///
  /// In en, this message translates to:
  /// **'Create new'**
  String get createNew;

  /// No description provided for @createNewGraph.
  ///
  /// In en, this message translates to:
  /// **'Create New Graph'**
  String get createNewGraph;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @renameGraph.
  ///
  /// In en, this message translates to:
  /// **'Rename Graph'**
  String get renameGraph;

  /// No description provided for @clone.
  ///
  /// In en, this message translates to:
  /// **'Clone'**
  String get clone;

  /// No description provided for @newName.
  ///
  /// In en, this message translates to:
  /// **'New name'**
  String get newName;

  /// No description provided for @graphName.
  ///
  /// In en, this message translates to:
  /// **'Graph name'**
  String get graphName;

  /// No description provided for @graphNameHint.
  ///
  /// In en, this message translates to:
  /// **'Building A, Floor 3...'**
  String get graphNameHint;

  /// No description provided for @newGraphDefaultName.
  ///
  /// In en, this message translates to:
  /// **'New graph'**
  String get newGraphDefaultName;

  /// No description provided for @graphCloneSuffix.
  ///
  /// In en, this message translates to:
  /// **'(copy)'**
  String get graphCloneSuffix;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @editNode.
  ///
  /// In en, this message translates to:
  /// **'Edit Node'**
  String get editNode;

  /// No description provided for @idCannotChange.
  ///
  /// In en, this message translates to:
  /// **'ID cannot be changed'**
  String get idCannotChange;

  /// No description provided for @autoFromName.
  ///
  /// In en, this message translates to:
  /// **'Auto-generated from name'**
  String get autoFromName;

  /// No description provided for @deleteGraphTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete graph?'**
  String get deleteGraphTitle;

  /// No description provided for @deleteGraphConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete graph permanently'**
  String get deleteGraphConfirm;

  /// No description provided for @deleteNodeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete node'**
  String get deleteNodeConfirm;

  /// No description provided for @sameNodeConnection.
  ///
  /// In en, this message translates to:
  /// **'Cannot connect node to itself'**
  String get sameNodeConnection;

  /// No description provided for @noGraphData.
  ///
  /// In en, this message translates to:
  /// **'No map data'**
  String get noGraphData;

  /// No description provided for @createGraphHint.
  ///
  /// In en, this message translates to:
  /// **'Create a map of your building in the editor'**
  String get createGraphHint;

  /// No description provided for @createGraph.
  ///
  /// In en, this message translates to:
  /// **'Create Map'**
  String get createGraph;

  /// No description provided for @routeInstructions.
  ///
  /// In en, this message translates to:
  /// **'Route Instructions'**
  String get routeInstructions;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @graphInfo.
  ///
  /// In en, this message translates to:
  /// **'Graph Information'**
  String get graphInfo;

  /// No description provided for @graphId.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get graphId;

  /// No description provided for @createdAt.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get createdAt;

  /// No description provided for @modifiedAt.
  ///
  /// In en, this message translates to:
  /// **'Modified'**
  String get modifiedAt;

  /// No description provided for @nodeCount.
  ///
  /// In en, this message translates to:
  /// **'Nodes'**
  String get nodeCount;

  /// No description provided for @searchNodes.
  ///
  /// In en, this message translates to:
  /// **'Search nodes'**
  String get searchNodes;

  /// No description provided for @noNodes.
  ///
  /// In en, this message translates to:
  /// **'No nodes yet'**
  String get noNodes;

  /// No description provided for @connectionCount.
  ///
  /// In en, this message translates to:
  /// **'Connections'**
  String get connectionCount;

  /// No description provided for @tour3dCountLabel.
  ///
  /// In en, this message translates to:
  /// **'3D tours'**
  String get tour3dCountLabel;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'total'**
  String get totalLabel;

  /// No description provided for @uniqueLabel.
  ///
  /// In en, this message translates to:
  /// **'unique'**
  String get uniqueLabel;

  /// No description provided for @cachedLabel.
  ///
  /// In en, this message translates to:
  /// **'cached'**
  String get cachedLabel;

  /// No description provided for @ofLabel.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get ofLabel;

  /// No description provided for @autoAliasesHint.
  ///
  /// In en, this message translates to:
  /// **'Basic aliases will be created automatically'**
  String get autoAliasesHint;

  /// No description provided for @switchLanguage.
  ///
  /// In en, this message translates to:
  /// **'Switch language'**
  String get switchLanguage;

  /// No description provided for @autoAliases.
  ///
  /// In en, this message translates to:
  /// **'Auto Aliases'**
  String get autoAliases;

  /// No description provided for @noAutoAliases.
  ///
  /// In en, this message translates to:
  /// **'No auto aliases'**
  String get noAutoAliases;

  /// No description provided for @enterNameForAliases.
  ///
  /// In en, this message translates to:
  /// **'Enter name to generate aliases'**
  String get enterNameForAliases;

  /// No description provided for @addAliasHint.
  ///
  /// In en, this message translates to:
  /// **'Add alias...'**
  String get addAliasHint;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @addAlias.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addAlias;

  /// No description provided for @aliasExists.
  ///
  /// In en, this message translates to:
  /// **'Alias already exists'**
  String get aliasExists;

  /// No description provided for @freezeAutoAliases.
  ///
  /// In en, this message translates to:
  /// **'Freeze: keep current auto aliases'**
  String get freezeAutoAliases;

  /// No description provided for @unfreezeAutoAliases.
  ///
  /// In en, this message translates to:
  /// **'Unfreeze: update when name changes'**
  String get unfreezeAutoAliases;

  /// No description provided for @disableAutoAliases.
  ///
  /// In en, this message translates to:
  /// **'Disable auto aliases'**
  String get disableAutoAliases;

  /// No description provided for @enableAutoAliases.
  ///
  /// In en, this message translates to:
  /// **'Enable auto aliases'**
  String get enableAutoAliases;

  /// No description provided for @autoAliasesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Auto aliases disabled'**
  String get autoAliasesDisabled;

  /// No description provided for @frozen.
  ///
  /// In en, this message translates to:
  /// **'Frozen'**
  String get frozen;

  /// No description provided for @freeze.
  ///
  /// In en, this message translates to:
  /// **'Freeze'**
  String get freeze;

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'ON'**
  String get on;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'OFF'**
  String get off;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @behavior.
  ///
  /// In en, this message translates to:
  /// **'Behavior'**
  String get behavior;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @confirmBefore3dTour.
  ///
  /// In en, this message translates to:
  /// **'Ask before opening 3D tour'**
  String get confirmBefore3dTour;

  /// No description provided for @confirm3dTourDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Open 3D tour?'**
  String get confirm3dTourDialogTitle;

  /// No description provided for @confirm3dTourDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'The following link will open in your browser:'**
  String get confirm3dTourDialogMessage;

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'Build graph-based routes from point A to point B with step-by-step instructions'**
  String get appDescription;

  /// No description provided for @textScale.
  ///
  /// In en, this message translates to:
  /// **'Text Size'**
  String get textScale;

  /// No description provided for @increaseTextScale.
  ///
  /// In en, this message translates to:
  /// **'Increase text'**
  String get increaseTextScale;

  /// No description provided for @decreaseTextScale.
  ///
  /// In en, this message translates to:
  /// **'Decrease text'**
  String get decreaseTextScale;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// No description provided for @fromHint.
  ///
  /// In en, this message translates to:
  /// **'main entrance, room 101...'**
  String get fromHint;

  /// No description provided for @nodeNameHint.
  ///
  /// In en, this message translates to:
  /// **'Room 101'**
  String get nodeNameHint;

  /// No description provided for @searchNodesHint.
  ///
  /// In en, this message translates to:
  /// **'Start typing...'**
  String get searchNodesHint;

  /// No description provided for @autoGenerateEnabled.
  ///
  /// In en, this message translates to:
  /// **'Auto-generate enabled'**
  String get autoGenerateEnabled;

  /// No description provided for @autoGenerateDisabled.
  ///
  /// In en, this message translates to:
  /// **'Auto-generate disabled'**
  String get autoGenerateDisabled;

  /// No description provided for @toHint.
  ///
  /// In en, this message translates to:
  /// **'room 301, lab 202...'**
  String get toHint;

  /// No description provided for @searchLanguage.
  ///
  /// In en, this message translates to:
  /// **'Search language or code...'**
  String get searchLanguage;

  /// No description provided for @noLanguagesFound.
  ///
  /// In en, this message translates to:
  /// **'No languages found'**
  String get noLanguagesFound;

  /// No description provided for @appPalette.
  ///
  /// In en, this message translates to:
  /// **'App Palette'**
  String get appPalette;

  /// No description provided for @paletteOceanBlue.
  ///
  /// In en, this message translates to:
  /// **'Ocean Blue'**
  String get paletteOceanBlue;

  /// No description provided for @paletteOceanBlueDesc.
  ///
  /// In en, this message translates to:
  /// **'Classic blue theme'**
  String get paletteOceanBlueDesc;

  /// No description provided for @paletteForestGreen.
  ///
  /// In en, this message translates to:
  /// **'Forest Green'**
  String get paletteForestGreen;

  /// No description provided for @paletteForestGreenDesc.
  ///
  /// In en, this message translates to:
  /// **'Natural green theme'**
  String get paletteForestGreenDesc;

  /// No description provided for @paletteSunsetOrange.
  ///
  /// In en, this message translates to:
  /// **'Sunset Orange'**
  String get paletteSunsetOrange;

  /// No description provided for @paletteSunsetOrangeDesc.
  ///
  /// In en, this message translates to:
  /// **'Warm orange theme'**
  String get paletteSunsetOrangeDesc;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'App theme'**
  String get themeMode;

  /// No description provided for @themeModeSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get themeModeSystem;

  /// No description provided for @themeModeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeModeLight;

  /// No description provided for @themeModeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeModeDark;

  /// No description provided for @downloadImages.
  ///
  /// In en, this message translates to:
  /// **'Download images'**
  String get downloadImages;

  /// No description provided for @clearImageCache.
  ///
  /// In en, this message translates to:
  /// **'Clear image cache'**
  String get clearImageCache;

  /// No description provided for @imagesDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Images downloaded'**
  String get imagesDownloaded;

  /// No description provided for @imagesCacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Image cache cleared'**
  String get imagesCacheCleared;

  /// No description provided for @noImagesToDownload.
  ///
  /// In en, this message translates to:
  /// **'No images to download'**
  String get noImagesToDownload;

  /// No description provided for @noCachedImages.
  ///
  /// In en, this message translates to:
  /// **'No cached images'**
  String get noCachedImages;

  /// No description provided for @downloadImagesProgress.
  ///
  /// In en, this message translates to:
  /// **'Downloading {downloaded} of {total}...'**
  String downloadImagesProgress(int downloaded, int total);

  /// No description provided for @downloadImagesComplete.
  ///
  /// In en, this message translates to:
  /// **'Downloaded {success} of {total}'**
  String downloadImagesComplete(int success, int total);
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
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
