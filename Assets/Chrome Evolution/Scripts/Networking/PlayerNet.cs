using UnityEngine;
using UnityEngine.InputSystem;

using Mirror;

using ChromeEvo.UI;
using ChromeEvo.Player;
using ChromeEvo.Weapons;
using ChromeEvo.Utils;
using ChromeEvo.Networking.Packets;

using Sirenix.OdinInspector;

using System.Collections.Generic;

namespace ChromeEvo.Networking
{
    #pragma warning disable 0649
    [RequireComponent(typeof(PlayerStats))]
    [ShowOdinSerializedPropertiesInInspector]
    public class PlayerNet : SerializedNetworkBehaviour
    {
        [SyncVar, ReadOnly]
        public byte ID;

        public PlayerStats Stats { get { return stats; } }

        [SerializeField]
        private GameObject lobbyPlayer;
        [SerializeField]
        private GameplayPlayer gameplayPlayer;
        [SerializeField]
        private Dictionary<WeaponType, Weapon> weapons = new Dictionary<WeaponType, Weapon>();

        private PlayerStats stats;
        private PacketHandler packetHandler;

        private bool connectedToLobbyUI = false;
        private LobbyMenu lobby;

        public override void OnStartLocalPlayer() => LevelManager.instance.LoadLobby();

        public override void OnStopClient()
        {
            // Remove the player from the dictionary when the player disconnects
            // this frees up the ID for any player that might reconnect
            ChromeNetworkManager.Instance.RemovePlayer(ID);

            base.OnStopClient();
        }

        /// <summary>
        /// Get the currently equipped weapon
        /// </summary>
        public Weapon GetWeapon()
        {
            return weapons[Stats.Weapon];
        }

        private void Start()
        {
            // Setup the correct player and add this player to the network manager dict
            lobbyPlayer.SetActive(true);
            gameplayPlayer.gameObject.SetActive(false);
            ChromeNetworkManager.Instance.AddPlayer(this);

            // Validate the stats and packet handler scripts
            RunableUtils.Validate(ref stats, gameObject);
            RunableUtils.Validate(ref packetHandler, gameObject);

            // Setup the packet handler
            RunableUtils.Setup(ref packetHandler);

            // Setup all weapons in the dictionary
            PlayerInput input = FindObjectOfType<PlayerInput>();
            foreach(var pair in weapons)
            {
                Weapon weapon = pair.Value;
                RunableUtils.Setup(ref weapon, input);
            }
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

        public void StartGame()
        {
            // Swap out the player objects
            lobbyPlayer.SetActive(false);
            gameplayPlayer.gameObject.SetActive(true);

            // Deactivate all weapons except the equipped one
            foreach(var pair in weapons)
            {
                if(pair.Key != Stats.Weapon)
                {
                    pair.Value.gameObject.SetActive(false);
                }
            }

            // Setup the gameplay player if we are the local player and load the 
            // gameplay scene
            if(isLocalPlayer)
            {
                LevelManager.instance.LoadGameplay();
                gameplayPlayer.Setup(this);
            }
        }

        public void Damage(float _damage)
        {
            Stats.Health -= _damage;

            if(Stats.IsDead)
            {
                // Die
            }
        }
    }
}