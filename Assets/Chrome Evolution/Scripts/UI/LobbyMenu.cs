using UnityEngine;
using UnityEngine.UI;

using ChromeEvo.Networking;

using TMPro;

namespace ChromeEvo.UI
{
    public class LobbyMenu : MonoBehaviour
    {
        [SerializeField]
        private LobbyPlayerDisplay[] playerDisplays;
        [SerializeField]
        private WeaponButton[] weaponButtons;
        [SerializeField]
        private Button startButton;
        [SerializeField]
        private Button readyButton;
        [SerializeField]
        private TMP_InputField playerNameInput;

        private ChromeNetworkManager chromeNetwork;
        private ChromePlayerNet localPlayer;

        public void OnPlayerConnect(ChromePlayerNet _player)
        {
            for(int i = 0; i < playerDisplays.Length; i++)
            {
                LobbyPlayerDisplay display = playerDisplays[i];

                if(!display.Filled)
                {
                    display.AssignPlayer(_player, i);
                    if(_player.isLocalPlayer)
                    {
                        localPlayer = _player;
                        readyButton.onClick.AddListener(display.ToggleReadyState);
                    }
                    break;
                }
            }
        }

        public void OnClickStart() => localPlayer.StartGame();

        public void SetReadyPlayer(int _index, bool _isReady) => playerDisplays[_index].SetReadyState(_isReady);

        // Start is called before the first frame update
        private void Start()
        {
            chromeNetwork = ChromeNetworkManager.singleton as ChromeNetworkManager;
            playerNameInput.onEndEdit.AddListener(OnEndEditName);
            startButton.interactable = false;

            foreach(WeaponButton button in weaponButtons)
            {
                button.Setup(this);
            }

            weaponButtons[0].SetActiveWeapon();
        }

        // Update is called once per frame
        private void Update()
        {
            if(chromeNetwork.IsHost)
            {
                foreach(LobbyPlayerDisplay display in playerDisplays)
                {
                    if(!display.Ready && display.Filled)
                    {
                        if(startButton.interactable)
                        {
                            startButton.interactable = false;
                        }

                        return;
                    }
                }

                if(!startButton.interactable)
                    startButton.interactable = true;
            }
        }

        private void OnEndEditName(string _name) => localPlayer?.SetName(_name);

        public void OnSelectWeapon(WeaponButton _button)
        {
            foreach(WeaponButton button in weaponButtons)
            {
                if(button.Equals(_button))
                    continue;

                button.Disable();
            }
        }
    }
}