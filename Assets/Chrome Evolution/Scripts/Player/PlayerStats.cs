using UnityEngine;

using Mirror;

namespace ChromeEvo.Player
{
    public class PlayerStats : NetworkBehaviour, IRunable
    {
        public float HealthVisualFactor { get { return Health / initialHealth; } }

        [SyncVar]
        public float Health = 0;
        [SyncVar]
        public string Username = "";

        [SerializeField]
        private float initialHealth = 10;
        
        public void Setup(params object[] _params)
        {
            ResetStats();
        }

        public void Run(params object[] _params)
        {

        }

        public void ResetStats()
        {
            Health = initialHealth;
        }
    }
}