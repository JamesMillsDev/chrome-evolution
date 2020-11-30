using ChromeEvo.API.Networking;

namespace ChromeEvo.Networking.Packets
{
    public class PacketDamagePlayer : Packet
    {
        private byte playerId = 0;
        private float damage = 0;

        public PacketDamagePlayer() : this(0, 0) { }

        public PacketDamagePlayer(byte _id, float _damage)
        {
            playerId = _id;
            damage = _damage;
        }

        public override void Deserialize(PacketBuffer _buffer)
        {
            playerId = _buffer.ReadByte();
            damage = _buffer.ReadFloat();
        }

        public override void Handle()
        {
            if(ChromeNetworkManager.Instance.TryGetPlayerForId(out PlayerNet player, playerId))
            {
                player.Damage(damage);
            }
        }

        public override void Serialize(PacketBuffer _buffer)
        {
            _buffer.WriteByte(playerId);
            _buffer.WriteFloat(damage);
        }
    }
}