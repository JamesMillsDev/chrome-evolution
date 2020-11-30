using UnityEngine;
using UnityEngine.UI;

using ChromeEvo.Weapons;
using ChromeEvo.Networking;
using ChromeEvo.Networking.Packets;

using TMPro;

namespace ChromeEvo.UI
{
    #pragma warning disable 0649
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

        [Space]

        [SerializeField]
        private GameObject mainScreen;
        [SerializeField]
        private GameObject customiseScreen;

        private ChromeNetworkManager chromeNetwork;
        private PlayerNet localPlayer;

        public void OnPlayerConnect(PlayerNet _player)
        {
            // Loop through all player displays in the list
            for(int i = 0; i < playerDisplays.Length; i++)
            {
                LobbyPlayerDisplay display = playerDisplays[i];

                // Attempt to fill this slot with the passed player
                if(!display.Filled)
                {
                    display.AssignPlayer(_player, i);

                    // If the player is local player, store them and add their 
                    // ready state function to the readyButton click event
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

        public void OnClickCustomise()
        {
            customiseScreen.SetActive(true);
            mainScreen.SetActive(false);
        }

        public void OnClickBackCustomise()
        {
            customiseScreen.SetActive(false);
            mainScreen.SetActive(true);
        }

        // Start is called before the first frame update
        private void Start()
        {
            // Store the network manager
            chromeNetwork = ChromeNetworkManager.Instance;

            // Setup the name input event and disable the start button
            playerNameInput.onEndEdit.AddListener(OnEndEditName);
            startButton.interactable = false;

            // Force the main screen to be active and setup all weapon buttons
            OnClickBackCustomise();
            foreach(WeaponButton button in weaponButtons)
            {
                button.Setup(this);
            }

            // Force the first weapon button to be active
            weaponButtons[0].SetActiveWeapon();
        }

        // Update is called once per frame
        private void Update()
        {
            if(chromeNetwork.IsHost)
            {
                // Loop through each player display and check if they are ready to play
                foreach(LobbyPlayerDisplay display in playerDisplays)
                {
                    if(!display.Ready && display.Filled)
                    {
                        // The slot is filled but the player isn't ready so disable the start button
                        // and return from the function
                        if(startButton.interactable)
                            startButton.interactable = false;

                        return;
                    }
                }

                // All filled spots are ready to play so activate the start button
                if(!startButton.interactable)
                    startButton.interactable = true;
            }
        }

        private void OnEndEditName(string _name) => 
            SendCustomisationPacket(_name, localPlayer != null ? localPlayer.Stats.Weapon : weaponButtons[0].Weapon);

        public void OnSelectWeapon(WeaponButton _button)
        {
            // Disable every button except the passed one
            foreach(WeaponButton button in weaponButtons)
            {
                if(button.Equals(_button))
                    continue;

                button.Disable();
            }

            // Update the customisation state of the current player
            SendCustomisationPacket(localPlayer != null ? localPlayer.Stats.Username : "", _button.Weapon);
        }

        private void SendCustomisationPacket(string _name, WeaponType _weapon)
        {
            // If the local player is null, ignore this call, otherwise send the customisation packet
            if(localPlayer == null)
                return;

            PacketHandler.SendPacket(new PacketUpdatePlayerCustomisation(localPlayer.ID, _name, _weapon));
        }
    }
}