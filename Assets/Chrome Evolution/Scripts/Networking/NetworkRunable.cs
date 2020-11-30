using UnityEngine;
using Mirror;

namespace ChromeEvo.Networking
{
    public abstract class NetworkRunable : SerializedNetworkBehaviour, IRunable
    {
        public abstract void Setup(params object[] _params);
        public abstract void Run(params object[] _params);
    }
}