{ pkgs, pkgs-unstable, nixcord, ... }:

{
  programs.nixcord = {
    enable = true;
    # discord = {
    #   vencord.enable = true;  # Use Vencord (default)
    #   equicord.enable = true;  # Or use Equicord instead (cannot enable both)
    # };
    # vesktop.enable = true;  # Vesktop
    equibop.enable = true;  # Equibop
    config = {
      discordBranch = "stable";
      minimizeToTray = true;
      arRPC = true;
      splashColor = "#DBDCDF";
      autoStartMinimized = true;
      disableMinSize = true;
      autoUpdate = true;
      autoUpdateNotification = true;
      quickCss = "quickCss.css";
      useQuickCSS = true;
      notifications = {
        timeout = 5018.050541516246;
        position = "bottom-right";
        useNative = "not-focused";
        logLimit = 25;
        missed = true;
      };
      plugins = {
        ChatInputButtonAPI.enabled = true;
        CommandsAPI.enabled = true;
        DynamicImageModalAPI.enabled = true;
        MemberListDecoratorsAPI.enabled = true;
        MessageAccessoriesAPI.enabled = true;
        MessageDecorationsAPI.enabled = true;
        MessageEventsAPI.enabled = true;
        MessagePopoverAPI.enabled = true;
        MessageUpdaterAPI.enabled = true;
        ServerListAPI.enabled = true;
        UserSettingsAPI.enabled = true;
        BetterFolders = {
          enabled = true;
          sidebar = true;
          sidebarAnim = true;
          closeAllFolders = false;
          closeAllHomeButton = false;
          closeOthers = false;
          forceOpen = false;
          keepIcons = false;
          showFolderIcon = 1;
        };

        BetterSettings = {
          enabled = true;
          disableFade = true;
          organizeMenu = true;
          eagerLoad = true;
        };

        BetterUploadButton.enabled = true;
        BiggerStreamPreview.enabled = true;
        BlurNSFW = {
          enabled = true;
          blurAmount = 10;
        };
        CallTimer.enabled = true;
        Decor = {
          enabled = true;
          baseUrl = "https://decor.fieryflames.dev";
        };
        DisableCallIdle.enabled = true;
        FakeNitro = {
          enabled = true;
          enableStickerBypass = true;
          enableStreamQualityBypass = true;
          enableEmojiBypass = true;
          transformEmojis = true;
          transformStickers = true;
          transformCompoundSentence = false;
          emojiSize = 48;
          hyperLinkText = "{{NAME}}";
          useHyperLinks = true;
          disableEmbedPermissionCheck = false;
          stickerSize = 160;
        };
        FakeProfileThemes = {
          enabled = true;
          nitroFirst = true;
        };
        FavoriteEmojiFirst.enabled = true;
        FixImagesQuality = {
          enabled = true;
          originalImagesInChat = false;
        };
        FixYoutubeEmbeds.enabled = true;
        FriendInvites.enabled = true;
        FriendsSince.enabled = true;
        GameActivityToggle = {
          enabled = true;
          oldIcon = false;
          location = "PANEL";
        };
        GifPaste.enabled = true;
        ImplicitRelationships = {
          enabled = true;
          sortByAffinity = true;
        };
        LoadingQuotes = {
          enabled = true;
          replaceEvents = true;
          enablePluginPresetQuotes = false;
          enableDiscordPresetQuotes = false;
          additionalQuotes = "I use Nix btw ❄️";
          additionalQuotesDelimiter = "|";
        };
        MemberCount = {
          enabled = true;
          memberList = true;
          toolTip = true;
          voiceActivity = true;
        };
        MessageLogger = {
          enabled = true;
          collapseDeleted = false;
          deleteStyle = "text";
          ignoreBots = false;
          ignoreSelf = false;
          ignoreUsers = "";
          ignoreChannels = "";
          ignoreGuilds = "";
          logEdits = true;
          logDeletes = true;
          inlineEdits = true;
        };
        MoreKaomoji.enabled = true;
        NewGuildSettings = {
          enabled = true;
          guild = true;
          messages = 3;
          everyone = true;
          role = true;
          highlights = true;
          events = true;
          showAllChannels = true;
        };
        NoF1.enabled = true;
        NoPendingCount = {
          enabled = true;
          hideFriendRequestsCount = true;
          hideMessageRequestsCount = true;
          hidePremiumOffersCount = true;
        };
        NoSystemBadge.enabled = true;
        NoTypingAnimation.enabled = true;
        OnePingPerDM = {
          enabled = true;
          channelToAffect = "both_dms";
          allowMentions = true;
          allowEveryone = false;
        };
        OpenInApp = {
          enabled = true;
          spotify = true;
          steam = true;
          epic = true;
          tidal = true;
          itunes = true;
        };
        PermissionsViewer = {
          enabled = true;
          permissionsSortOrder = 0;
        };
        PinDMs = {
          enabled = true;
          canCollapseDmSection = false;
          userBasedCategoryList = {
            "548454674622316544" = [
              {
                id = "kug86hxceqe";
                name = "❤️❤️❤️❤️❤️❤️❤️";
                color = 10070709;
                collapsed = false;
                channels = [ "1126164779300560936" ];
              }
            ];
          };
          pinOrder = 0;
        };
        QuickMention.enabled = true;
        ReadAllNotificationsButton.enabled = true;
        ReviewDB = {
          enabled = true;
          notifyReviews = true;
        };
        ShikiCodeblocks = {
          enabled = true;
          theme = "https://cdn.jsdelivr.net/gh/shikijs/textmate-grammars-themes@bc5436518111d87ea58eb56d97b3f9bec30e6b83/packages/tm-themes/themes/dark-plus.json";
          tryHljs = "SECONDARY";
          useDevIcon = "GREYSCALE";
          bgOpacity = 100;
        };
        ShowHiddenChannels = {
          enabled = true;
          showMode = 0;
          hideUnreads = true;
        };
        ShowHiddenThings = {
          enabled = true;
          showTimeouts = true;
          showInvitesPaused = true;
          showModView = true;
        };
        SpotifyCrack = {
          enabled = true;
          noSpotifyAutoPause = true;
          keepSpotifyActivityOnIdle = false;
        };
        SpotifyShareCommands.enabled = true;
        SuperReactionTweaks = {
          enabled = true;
          superReactByDefault = true;
          unlimitedSuperReactionPlaying = false;
          superReactionPlayingLimit = 0;
        };
        Translate = {
          enabled = true;
          service = "google";
          deeplApiKey = "";
          autoTranslate = false;
          showAutoTranslateTooltip = true;
        };
        UnsuppressEmbeds.enabled = true;
        USRBG = {
          enabled = true;
          voiceBackground = true;
          nitroFirst = true;
        };
        ValidUser.enabled = true;
        ViewIcons.enabled = true;
        VolumeBooster = {
          enabled = true;
          multiplier = 2;
        };
        WhoReacted.enabled = true;
        YoutubeAdblock.enabled = true;
        BadgeAPI.enabled = true;
        NoTrack = {
          enabled = true;
          disableAnalytics = true;
        };
        Settings = {
          enabled = true;
          settingsLocation = "aboveNitro";
        };
        SupportHelper.enabled = true;
        ExpressionCloner.enabled = true;
        EquicordToolbox.enabled = true;
        NewPluginsManager.enabled = true;
        EquicordHelper = {
          enabled = true;
          disableCreateDMButton = false;
          disableDMContextMenu = false;
          noMirroredCamera = false;
        };
        VCSupport.enabled = true;
        DisableDeepLinks.enabled = true;
        WebContextMenus.enabled = true;
        WebKeybinds.enabled = true;
        WebScreenShareFixes.enabled = true;
      };
    };
  };
}