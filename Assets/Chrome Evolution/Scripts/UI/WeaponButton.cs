using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

using ChromeEvo.Weapons;

namespace ChromeEvo.UI
{
#pragma warning disable 0649
    [RequireComponent(typeof(Button))]
    public class WeaponButton : MonoBehaviour
    {
        public WeaponType Weapon { get { return weapon; } }

        private Button button;
        private LobbyMenu lobby;

        [SerializeField]
        private Sprite active;
        [SerializeField]
        private Sprite inactive;
        [SerializeField]
        private WeaponType weapon;

        public void Setup(LobbyMenu _menu)
        {
            button = gameObject.GetComponent<Button>();
            button.onClick.AddListener(SetActiveWeapon);

            lobby = _menu;
        }

        public void SetActiveWeapon()
        {
            button.image.sprite = active;
            lobby.OnSelectWeapon(this);
        }

        public void Disable()
        {
            button.image.sprite = inactive;
        }
    }
}