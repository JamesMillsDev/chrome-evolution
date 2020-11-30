using UnityEngine;
using UnityEngine.UI;

using TMPro;

using ChromeEvo.Networking;
using ChromeEvo.Networking.Packets;

namespace ChromeEvo.UI
{
#pragma warning disable 0649
    public class LobbyPlayerDisplay : MonoBehaviour
    {
        public bool Filled { get { return button.interactable; } }
        public bool Ready { get; private set; } = false;

        [SerializeField]
        private TextMeshProUGUI playerName;
        [SerializeField]
        private Button button;
        [SerializeField]
        private Image readyIndicator;
        [SerializeField]
        private Sprite readySprite;
        [SerializeField]
        private Sprite notReadySprite;

        private PlayerNet player;
        private int index;

        public void AssignPlayer(PlayerNet _player, int _index)
        {
            player = _player;
            index = _index;
            button.interactable = true;
            readyIndicator.gameObject.SetActive(true);
        }

        public void ToggleReadyState()
        {
            SetReadyState(!Ready);
            PacketHandler.SendPacket(new PacketReadyPlayer(Ready, index));
        }

        public void SetReadyState(bool _isReady) => Ready = _isReady;

        private void Awake()
        {
            button.interactable = false;
            readyIndicator.gameObject.SetActive(false);
        }

        // Update is called once per frame
        void Update()
        {
            playerName.text = player != null && !string.IsNullOrEmpty(player.Stats.Username) ? player.Stats.Username : "Player";
            readyIndicator.sprite = Ready ? readySprite : notReadySprite;
        }
    }
}