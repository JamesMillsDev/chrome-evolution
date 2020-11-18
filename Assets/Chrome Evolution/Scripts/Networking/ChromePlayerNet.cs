using UnityEngine;

using Mirror;

using ChromeEvo.UI;
using ChromeEvo.Player;
using ChromeEvo.Weapons;

using Sirenix.OdinInspector;
using Sirenix.Serialization;

using System.Collections.Generic;

namespace ChromeEvo.Networking
{
    [RequireComponent(typeof(PlayerStats))]
    [ShowOdinSerializedPropertiesInInspector]
    public class ChromePlayerNet : NetworkBehaviour, ISerializationCallbackReceiver, ISupportsPrefabSerialization
    {
        public PlayerStats Stats { get { return stats; } }

        [SerializeField]
        private GameObject lobbyPlayer;
        [SerializeField]
        private GameplayPlayer gameplayPlayer;
        [SerializeField]
        private Dictionary<WeaponType, Weapon> weapons = new Dictionary<WeaponType, Weapon>();

        private PlayerStats stats;

        private bool connectedToLobbyUI = false;
        private LobbyMenu lobby;

        private WeaponType weapon;

        public override void OnStartLocalPlayer() => LevelManager.instance.LoadLobby();

        public void ReadyPlayer(int _index, bool _isReady)
        {
            if(isLocalPlayer)
                CmdReadyPlayer(_index, _isReady);
        }

        public void StartGame()
        {
            if(isLocalPlayer)
                CmdStartGame();
        }

        public void SetName(string _name)
        {
            if(isLocalPlayer)
                CmdSetPlayerName(_name);
        }

        private void Start()
        {
            lobbyPlayer.SetActive(true);
            gameplayPlayer.gameObject.SetActive(false);

            stats = gameObject.GetComponent<PlayerStats>();
        }

        private void Update()
        {
            if(lobbyPlayer.activeSelf && lobby == null)
                lobby = FindObjectOfType<LobbyMenu>();

            if(!connectedToLobbyUI && lobby != null)
            {
                lobby.OnPlayerConnect(this);
                connectedToLobbyUI = true;
            }
        }

        [Command] public void CmdReadyPlayer(int _index, bool _isReady) => RpcReadyPlayer(_index, _isReady);
        [ClientRpc] public void RpcReadyPlayer(int _index, bool _isReady) => lobby?.SetReadyPlayer(_index, _isReady);

        [Command] public void CmdSetPlayerName(string _name) => RpcSetPlayerName(_name);
        [ClientRpc] public void RpcSetPlayerName(string _name) => Stats.Username = _name;

        [Command] public void CmdStartGame() => RpcStartGame();
        [ClientRpc]
        public void RpcStartGame()
        {
            ChromePlayerNet[] players = FindObjectsOfType<ChromePlayerNet>();

            foreach(ChromePlayerNet player in players)
            {
                player.lobbyPlayer.SetActive(false);
                player.gameplayPlayer.gameObject.SetActive(true);

                if(player.isLocalPlayer)
                {
                    LevelManager.instance.LoadGameplay();
                    player.gameplayPlayer.Setup(this);
                }
            }
        }

        [SerializeField, HideInInspector]
        private SerializationData serializationData;

        SerializationData ISupportsPrefabSerialization.SerializationData { get { return this.serializationData; } set { this.serializationData = value; } }

        void ISerializationCallbackReceiver.OnAfterDeserialize()
        {
            UnitySerializationUtility.DeserializeUnityObject(this, ref this.serializationData);
        }

        void ISerializationCallbackReceiver.OnBeforeSerialize()
        {
            UnitySerializationUtility.SerializeUnityObject(this, ref this.serializationData);
        }
    }
}