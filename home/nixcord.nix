{ pkgs, pkgs-unstable, nixcord, ... }:

{
  programs.nixcord = {
    enable = true;
    # discord = {
    #   vencord.enable = true;
    #   equicord.enable = true;  # Cannot enable both
    # };
    # vesktop.enable = true;
    equibop.enable = true;
    quickCss = builtins.readFile ./quickCss.css;
    config = {
      disableMinSize = true;
      autoUpdate = true;
      autoUpdateNotification = true;
      useQuickCss = true;
      plugins = {
        betterFolders = {
          enable = true;
          sidebar = true;
          sidebarAnim = true;
          closeAllFolders = false;
          closeAllHomeButton = false;
          closeOthers = false;
          forceOpen = false;
          keepIcons = false;
          showFolderIcon = 1;
        };
        betterSettings = {
          enable = true;
          disableFade = true;
          organizeMenu = true;
          eagerLoad = true;
        };
        betterUploadButton.enable = true;
        biggerStreamPreview.enable = true;
        BlurNSFW = {
          enable = true;
          blurAmount = 10;
        };
        callTimer.enable = true;
        decor.enable = true;
        disableCallIdle.enable = true;
        fakeNitro = {
          enable = true;
          enableStickerBypass = true;
          enableStreamQualityBypass = true;
          enableEmojiBypass = true;
          transformEmojis = true;
          transformStickers = true;
          transformCompoundSentence = false;
          emojiSize = 48.0;
          hyperLinkText = "{{NAME}}";
          useEmojiHyperLinks = true;
          useStickerHyperLinks = true;
          disableEmbedPermissionCheck = false;
          stickerSize = 160.0;
        };
        fakeProfileThemes = {
          enable = true;
          nitroFirst = true;
        };
        favoriteEmojiFirst.enable = true;
        fixImagesQuality = {
          enable = true;
          originalImagesInChat = false;
        };
        fixYoutubeEmbeds.enable = true;
        friendInvites.enable = true;
        friendsSince.enable = true;
        gameActivityToggle = {
          enable = true;
          oldIcon = false;
          location = "PANEL";
        };
        gifPaste.enable = true;
        implicitRelationships = {
          enable = true;
          sortByAffinity = true;
        };
        loadingQuotes = {
          enable = true;
          replaceEvents = true;
          enablePluginPresetQuotes = false;
          enableDiscordPresetQuotes = false;
          additionalQuotes = "I use Nix btw ❄️";
          additionalQuotesDelimiter = "|";
        };
        memberCount = {
          enable = true;
          memberList = true;
          toolTip = true;
          voiceActivity = true;
        };
        messageLogger = {
          enable = true;
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
        moreKaomoji.enable = true;
        newGuildSettings = {
          enable = true;
          guild = true;
          messages = 3;
          everyone = true;
          role = true;
          highlights = true;
          events = true;
          showAllChannels = true;
        };
        noF1.enable = true;
        noPendingCount = {
          enable = true;
          hideFriendRequestsCount = true;
          hideMessageRequestsCount = true;
          hidePremiumOffersCount = true;
        };
        noSystemBadge.enable = true;
        noTypingAnimation.enable = true;
        OnePingPerDM = {
          enable = true;
          channelToAffect = "both_dms";
          allowMentions = true;
          allowEveryone = false;
        };
        openInApp.enable = true;
        permissionsViewer = {
          enable = true;
          permissionsSortOrder = 0;
        };
        PinDMs = {
          enable = true;
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
        quickMention.enable = true;
        readAllNotificationsButton.enable = true;
        shikiCodeblocks = {
          enable = true;
          theme = "https://raw.githubusercontent.com/shikijs/textmate-grammars-themes/bc5436518111d87ea58eb56d97b3f9bec30e6b83/packages/tm-themes/themes/dark-plus.json";
          tryHljs = "SECONDARY";
          useDevIcon = "GREYSCALE";
          bgOpacity = 100.0;
        };
        showHiddenChannels = {
          enable = true;
          showMode = 0;
          defaultAllowedUsersAndRolesDropdownState = true;
        };
        showHiddenThings.enable = true;
        spotifyCrack = {
          enable = true;
          noSpotifyAutoPause = true;
          keepSpotifyActivityOnIdle = false;
        };
        spotifyShareCommands.enable = true;
        startupTimings.enable = true;
        superReactionTweaks = {
          enable = true;
          superReactByDefault = true;
          unlimitedSuperReactionPlaying = false;
          superReactionPlayingLimit = 3.0;
        };
        translate = {
          enable = true;
          service = "google";
          deeplApiKey = "";
          autoTranslate = false;
          showAutoTranslateTooltip = true;
        };
        toastNotifications = {
          enable = true;
          determineServerNotifications = true;
          friendServerNotifications = false;
          groupMessages = false;
          directMessages = true;
          notifyFor = "1126164779300560936";
          position = "top-right";
          renderImages = true;
          timeout = 5.0;
        };
        unsuppressEmbeds.enable = true;
        USRBG = {
          enable = true;
          voiceBackground = true;
          nitroFirst = true;
        };
        validUser.enable = true;
        viewIcons.enable = true;
        voiceDownload.enable = true;
        volumeBooster = {
          enable = true;
          multiplier = 2.0  ;
        };
        whoReacted.enable = true;
        youtubeAdblock.enable = true;
        expressionCloner.enable = true;
        equicordToolbox.enable = true;
        newPluginsManager.enable = true;
        equicordHelper = {
          enable = true;
          disableDMContextMenu = false;
          noMirroredCamera = false;
        };
        disableDeepLinks.enable = true;
        webContextMenus.enable = true;
        webKeybinds.enable = true;
        webRichPresence.enable = true;
        webScreenShareFixes.enable = true;
      };
    };
  };
}