using UnityEngine;

namespace ChromeEvo.Player
{
    public class PlayerStats : Runable
    {
        public float HealthVisualFactor { get { return health / initialHealth; } }

        [SerializeField]
        private float initialHealth = 10;

        private float health = 0;

        // Start is called just before any of the Update methods is called the first time
        public override void Setup(params object[] _params)
        {
            ResetStats();
        }

        public override void Run(params object[] _params)
        {

        }

        public void ResetStats()
        {
            health = initialHealth;
        }
    }
}