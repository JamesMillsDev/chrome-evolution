using UnityEngine;
using ChromeEvo.API.Networking;

namespace ChromeEvo.Networking.Packets
{
    public class PacketStartGame : Packet
    {
        public override void Deserialize(PacketBuffer _buffer)
        {

        }

        public override void Handle()
        {
            PlayerNet[] players = ChromeNetworkManager.Instance.GetPlayers();

            foreach(PlayerNet player in players)
            {
                player.StartGame();
            }
        }

        public override void Serialize(PacketBuffer _buffer)
        {

        }
    }
}