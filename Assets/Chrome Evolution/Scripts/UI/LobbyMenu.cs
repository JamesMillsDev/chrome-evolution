using UnityEngine;
using UnityEngine.UI;

using ChromeEvo.Networking;

using TMPro;

using Mirror;

namespace ChromeEvo.UI
{
    public class LobbyMenu : MonoBehaviour
    {
        [SerializeField]
        private LobbyPlayerDisplay[] playerDisplays;
        [SerializeField]
        private Button startButton;
        [SerializeField]
        private Button readyButton;
        [SerializeField]
        private TMP_InputField playerName;

        private ChromeNetworkManager chromeNetwork;
        private ChromePlayerNet localPlayer;

        public void OnPlayerConnect(ChromePlayerNet _player)
        {
            for (int i = 0; i < playerDisplays.Length; i++)
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

        // Start is called before the first frame update
        private void Start()
        {
            chromeNetwork = ChromeNetworkManager.singleton as ChromeNetworkManager;
            playerName.onEndEdit.AddListener(OnEndEditName);
        }

        // Update is called once per frame
        private void Update()
        {
            if(chromeNetwork.IsHost)
            {
                foreach(LobbyPlayerDisplay display in playerDisplays)
                {
                    if (display.Ready || !display.Filled)
                        continue;

                    startButton.interactable = false;
                    return;
                }

                startButton.interactable = true;
            }
            else
            {
                startButton.interactable = false;
            }
        }

        public void OnClickStart()
        {
            localPlayer.StartGame();
        }

        private void OnEndEditName(string _name)
        {
            if(localPlayer != null)
            {
                localPlayer.SetName(_name);
            }
        }

        public void SetReadyPlayer(int _index, bool _isReady)
        {
            playerDisplays[_index].SetReadyState(_isReady);
        }
    }
}