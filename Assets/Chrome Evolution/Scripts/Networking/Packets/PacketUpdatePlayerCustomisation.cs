using ChromeEvo.API.Networking;
using ChromeEvo.Weapons;

namespace ChromeEvo.Networking.Packets
{
    public class PacketUpdatePlayerCustomisation : Packet
    {
        private byte playerId = 0;
        private string playerName = "";
        private WeaponType weapon;

        public PacketUpdatePlayerCustomisation() : this(0, "", WeaponType.Pistol) { }

        public PacketUpdatePlayerCustomisation(byte _id, string _name, WeaponType _weapon)
        {
            playerId = _id;
            playerName = _name;
            weapon = _weapon;
        }

        public override void Deserialize(PacketBuffer _buffer)
        {
            playerId = _buffer.ReadByte();
            playerName = _buffer.ReadString();
            weapon = (WeaponType)_buffer.ReadInt();
        }

        public override void Handle()
        {
            if(ChromeNetworkManager.Instance.TryGetPlayerForId(out PlayerNet player, playerId))
            {
                player.Stats.Customise(playerName, weapon);
            }
        }

        public override void Serialize(PacketBuffer _buffer)
        {
            _buffer.WriteByte(playerId);
            _buffer.WriteString(playerName);
            _buffer.WriteInt((int)weapon);
        }
    }
}