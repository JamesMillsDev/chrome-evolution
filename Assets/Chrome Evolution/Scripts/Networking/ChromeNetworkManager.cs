using Mirror;

using UnityEngine;

using System.Linq;
using System.Collections.Generic;

namespace ChromeEvo.Networking
{
    public class ChromeNetworkManager : NetworkManager
    {
        public static ChromeNetworkManager Instance { get { return singleton as ChromeNetworkManager; } }

        private Dictionary<byte, PlayerNet> players = new Dictionary<byte, PlayerNet>();

        public bool IsHost { get; private set; } = false;

        public override void OnStartHost() => IsHost = true;

        public bool TryGetPlayerForId(out PlayerNet _player, byte _playerId)
        {
            // If the player is present, set it and return true
            if(players.ContainsKey(_playerId))
            {
                _player = players[_playerId];
                return true;
            }

            // The player isn't present so return false and set the player to null
            _player = null;
            return false;
        }

        public int GetPlayerCount()
        {
            return players.Count - 1;
        }

        public PlayerNet[] GetPlayers()
        {
            return players.Values.ToArray();
        }

        public override void OnServerAddPlayer(NetworkConnection _connection)
        {
            Transform startPos = GetStartPosition();

            GameObject playerObj = startPos != null
                ? Instantiate(playerPrefab, startPos.position, startPos.rotation)
                : Instantiate(playerPrefab);

            AssignPlayerID(playerObj);

            NetworkServer.AddPlayerForConnection(_connection, playerObj);
        }

        protected void AssignPlayerID(GameObject _playerObject)
        {
            // Loop through all players to find the next available ID
            byte playerId = 0;
            for(int i = 0; i < players.Count; i++)
            {
                if(players.ContainsKey(playerId))
                {
                    playerId++;
                    continue;
                }

                break;
            }

            PlayerNet player = _playerObject.GetComponent<PlayerNet>();
            player.ID = playerId;
        }

        public void AddPlayer(PlayerNet _player)
        {
            if(!players.ContainsKey(_player.ID))
            {
                players.Add(_player.ID, _player);
            }
        }

        public void RemovePlayer(byte _id)
        {
            players.Remove(_id);
        }
    }
}