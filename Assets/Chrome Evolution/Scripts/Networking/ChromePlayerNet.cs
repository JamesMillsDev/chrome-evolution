using UnityEngine;
using UnityEngine.SceneManagement;

using Mirror;

using ChromeEvo.UI;
using ChromeEvo.Player;

namespace ChromeEvo.Networking
{
    [RequireComponent(typeof(PlayerStats))]
    public class ChromePlayerNet : NetworkBehaviour
    {
        public PlayerStats Stats { get { return stats; } }

        [SerializeField]
        private GameObject lobbyPlayer;
        [SerializeField]
        private GameplayPlayer gameplayPlayer;

        private PlayerStats stats;

        private bool connectedToLobbyUI = false;

        private void Start()
        {
            lobbyPlayer.SetActive(true);
            gameplayPlayer.gameObject.SetActive(false);

            stats = gameObject.GetComponent<PlayerStats>();
        }

        public override void OnStartLocalPlayer()
        {
            SceneManager.LoadSceneAsync("Lobby UI", LoadSceneMode.Additive);
        }

        private void Update()
        {
            if(!connectedToLobbyUI)
            {
                LobbyMenu lobby = FindObjectOfType<LobbyMenu>();
                if(lobby != null)
                {
                    lobby.OnPlayerConnect(this);
                    connectedToLobbyUI = true;
                }
            }
        }

        public void ReadyPlayer(int _index, bool _isReady)
        {
            if(isLocalPlayer)
            {
                CmdReady(_index, _isReady);
            }
        }

        [Command]
        public void CmdReady(int _index, bool _isReady)
        {
            RpcReady(_index, _isReady);
        }

        [ClientRpc]
        public void RpcReady(int _index, bool _isReady)
        {
            FindObjectOfType<LobbyMenu>().SetReadyPlayer(_index, _isReady);
        }

        public void StartGame()
        {
            if(isLocalPlayer)
            {
                CmdStartGame();
            }
        }

        [Command]
        public void CmdStartGame()
        {
            RpcStartGame();
        }

        [ClientRpc]
        public void RpcStartGame()
        {
            SceneManager.LoadSceneAsync("Gameplay", LoadSceneMode.Additive);
            SceneManager.UnloadSceneAsync("Lobby UI");
            lobbyPlayer.SetActive(false);
            gameplayPlayer.gameObject.SetActive(true);

            if(isLocalPlayer)
            {
                gameplayPlayer.Setup(this);
            }
        }

        public void SetName(string _name)
        {
            if(isLocalPlayer)
            {
                CmdSetName(_name);
            }
        }

        [Command]
        public void CmdSetName(string _name)
        {
            RpcSetName(_name);
        }

        [ClientRpc]
        public void RpcSetName(string _name)
        {
            Stats.Username = _name;
        }
    }
}