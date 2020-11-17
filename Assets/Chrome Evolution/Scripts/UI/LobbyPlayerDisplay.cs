using UnityEngine;
using UnityEngine.UI;

using TMPro;

using ChromeEvo.Networking;

namespace ChromeEvo.UI
{
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

        private ChromePlayerNet player;
        private int index;

        public void AssignPlayer(ChromePlayerNet _player, int _index)
        {
            player = _player;
            index = _index;
            button.interactable = true;
            readyIndicator.gameObject.SetActive(true);
        }

        public void ToggleReadyState()
        {
            SetReadyState(!Ready);
            player.ReadyPlayer(index, Ready);
        }

        public void SetReadyState(bool _isReady) => Ready = _isReady;

        private void Start()
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