using UnityEngine;

using Mirror;

using Sirenix.OdinInspector;

using ChromeEvo.Weapons;

namespace ChromeEvo.Networking
{
    public class PlayerStats : NetworkRunable
    {
        public float HealthVisualFactor { get { return Health / initialHealth; } }
        public bool IsDead { get { return Health <= 0f; } }

        [SyncVar, ReadOnly]
        public float Health = 0;
        [SyncVar, ReadOnly]
        public string Username = "";
        [ReadOnly]
        public WeaponType Weapon = WeaponType.Pistol;

        [SerializeField]
        private float initialHealth = 10;
        
        public override void Setup(params object[] _params)
        {
            ResetStats();
        }

        public override void Run(params object[] _params)
        {
            // #emptybro
        }

        public void Customise(string _name, WeaponType _weapon)
        {
            this.Username = _name;
            this.Weapon = _weapon;
        }

        public void ResetStats()
        {
            Health = initialHealth;
        }
    }
}