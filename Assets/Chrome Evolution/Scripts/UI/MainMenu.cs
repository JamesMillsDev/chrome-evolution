using UnityEngine;

using Mirror;

using TMPro;

namespace ChromeEvo.UI
{
#pragma warning disable 0649
    public class MainMenu : MonoBehaviour
    {
        [SerializeField]
        private GameObject mainMenu;
        [SerializeField]
        private GameObject connectMenu;

        [Header("Components")]
        [SerializeField]
        private TMP_InputField addressInput;

        // Start is called before the first frame update
        void Start()
        {
            mainMenu.SetActive(true);
            connectMenu.SetActive(false);

            Cursor.visible = true;
            Cursor.lockState = CursorLockMode.None;
        }

        public void OnClickStart()
        {
            mainMenu.SetActive(false);
            connectMenu.SetActive(true);
        }

        public void OnClickConnectCancel()
        {
            mainMenu.SetActive(true);
            connectMenu.SetActive(false);
        }

        public void OnClickQuit()
        {
#if UNITY_EDITOR
            UnityEditor.EditorApplication.isPlaying = false;
#else
            Application.Quit();
#endif
        }

        public void OnClickHost() => NetworkManager.singleton.StartHost();

        public void OnClickConnect()
        {
            NetworkManager.singleton.networkAddress = string.IsNullOrEmpty(addressInput.text) ? "localhost" : addressInput.text;
            NetworkManager.singleton.StartClient();
        }
    }
}