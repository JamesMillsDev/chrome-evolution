using Mirror;

using Type = System.Type;
using System.Collections.Generic;
using Activator = System.Activator;

using ChromeEvo.Networking;

namespace ChromeEvo.API.Networking
{
	public abstract class PacketHandler : NetworkRunable
	{
        public static PacketHandler Instance
        {
            get;
            private set;
        }

        private static int nextID = 0;

        private Dictionary<Type, int> registeredPacketsByType = new Dictionary<Type, int>();
        private Dictionary<int, Type> registeredPacketsByID = new Dictionary<int, Type>();

        public static void ResetIDs()
        {
            nextID = 0;
        }

        protected void Awake()
        {
			RegisterPackets();
        }

		// Use this for initialization
		public override void Setup(params object[] _params)
		{
            if(Instance == null && isLocalPlayer)
            {
                Instance = this; 
            }
            else
            {
                enabled = false;
                return;
            }
		}

        public override void Run(params object[] _params)
        {

        }

        public static void SendPacket(Packet _packet)
        {
            Instance.SendPacketInternal(_packet);
        }

        protected void SendPacketInternal(Packet _packet)
        {
            if (isLocalPlayer)
            {
                var packetType = _packet.GetType();
                if (registeredPacketsByType.ContainsKey(packetType))
                {
                    PacketBuffer buffer = new PacketBuffer();
                    _packet.Serialize(buffer);
                    buffer.Serialize();

                    CmdSendPacket(buffer, registeredPacketsByType[packetType]);

                    return;
                }

                throw new PacketNotRegisteredException(packetType);
            }
        }

        [Command]
        /// <summary>
        /// Do not directly call this function, call BroadcastPacket instead.
        /// </summary>
        public void CmdSendPacket(PacketBuffer _buffer, int _id)
        {
            RpcRecievePacket(_buffer, _id);
        }

        [ClientRpc]
        public void RpcRecievePacket(PacketBuffer _buffer, int _id)
        {
            if (registeredPacketsByID.ContainsKey(_id))
            {
                _buffer.Deserialize();
                var type = registeredPacketsByID[_id];
                var instance = Activator.CreateInstance(type);
                var packet = instance as Packet;
                packet.Deserialize(_buffer);
                packet.Handle();
            }
        }

        protected abstract void RegisterPackets();

        protected void RegisterPacket<T>() where T : Packet
        {
            Type packet = typeof(T);
            if (!registeredPacketsByType.ContainsKey(packet))
            {
                int id = nextID++;
                registeredPacketsByType.Add(packet, id);
                registeredPacketsByID.Add(id, packet);
            }
        }
    }
}