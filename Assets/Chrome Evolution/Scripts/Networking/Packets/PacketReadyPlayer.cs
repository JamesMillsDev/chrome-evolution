using UnityEngine;

using ChromeEvo.UI;
using ChromeEvo.API.Networking;

namespace ChromeEvo.Networking.Packets
{
    public class PacketReadyPlayer : Packet
    {
        private bool isReady = true;
        private int index = 0;

        public PacketReadyPlayer() : this(true, 0) { }

        public PacketReadyPlayer(bool _isReady, int _index)
        {
            isReady = _isReady;
            index = _index;
        }

        public override void Deserialize(PacketBuffer _buffer)
        {
            isReady = _buffer.ReadBool();
            index = _buffer.ReadInt();
        }

        public override void Handle()
        {
            LobbyMenu lobby = GameObject.FindObjectOfType<LobbyMenu>();

            if(lobby != null)
            {
                lobby.SetReadyPlayer(index, isReady);
            }
        }

        public override void Serialize(PacketBuffer _buffer)
        {
            _buffer.WriteBool(isReady);
            _buffer.WriteInt(index);
        }
    }
}