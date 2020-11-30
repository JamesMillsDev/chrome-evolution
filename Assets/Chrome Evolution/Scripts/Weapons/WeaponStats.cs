using UnityEngine;

using Sirenix.OdinInspector;

namespace ChromeEvo.Weapons
{
    [CreateAssetMenu(menuName = "Chrome Evo/Weapon Stats", fileName = "NewWeaponStats")]
    public class WeaponStats : SerializedScriptableObject
    {
        public int ClipSize { get { return MaxAmmo / ClipCount; } }

        public bool IsAutomatic = false;

        [Space]

        [Range(0.1f, 5)]
        public float Damage = 0.1f;
        [Range(0f, 5f)]
        public float FireRate = 1f;
        [Range(5, 20)]
        public float Range = 5;
        [Range(0, 0.05f)]
        public float Sway = 0.05f;

        [Space]

        [Min(1)]
        public int MaxAmmo = 1;
        [Min(1)]
        public int ClipCount = 1;
    }
}