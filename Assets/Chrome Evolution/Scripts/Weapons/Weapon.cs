using System.Collections;

using UnityEngine;
using UnityEngine.InputSystem;

using ChromeEvo.Utils;
using ChromeEvo.Networking;
using ChromeEvo.Networking.Packets;

namespace ChromeEvo.Weapons
{
    #pragma warning disable 0649
    public class Weapon : Runable
    {
        public int ClipAmmo { get { return clipAmmo; } }
        public int TotalAmmo { get { return totalAmmo; } }

        private PlayerInput input;
        private InputAction fireAction;
        private InputAction reloadAction;
        private InputAction scopeAction;

        [SerializeField]
        private WeaponStats stats;
        [SerializeField]
        private Transform shootPos;

        protected bool isReloading = false;
        protected bool isFiring = false;
        protected bool isScoping = false;
        protected bool isCoolingDown = false;
        protected bool needsReload = false;
        protected bool canShoot = true;

        protected int clipAmmo = 0;
        protected int totalAmmo = 0;

        public override void Setup(params object[] _params)
        {
            // Store the input reference and get the actions
            input = (PlayerInput)_params[0];
            InputUtils.CacheAndEnable(ref input, ref fireAction, "Fire");
            InputUtils.CacheAndEnable(ref input, ref reloadAction, "Reload");
            InputUtils.CacheAndEnable(ref input, ref scopeAction, "Scope");

            // Setup the input events
            InputUtils.SubscribeEvents(ref fireAction, OnFirePerformed, OnFireCanceled);
            InputUtils.SubscribeEvents(ref reloadAction, OnReloadPerformed, OnReloadCanceled);
            InputUtils.SubscribeEvents(ref scopeAction, OnScopePerformed, OnScopeCanceled);

            // Set the default values of the ammo
            totalAmmo = stats.MaxAmmo - stats.ClipSize;
            clipAmmo = stats.ClipSize;
        }

        public override void Run(params object[] _params)
        {
            // If we are completely out of ammo and we don't need to reload, ignore the shoot loop
            if(!needsReload && clipAmmo == 0)
                return;

            // if we aren't an automatic weapon, we are cooled down, not firing and the canShoot flag is
            // false, reset it
            if(!stats.IsAutomatic && !isCoolingDown && !canShoot && !isFiring)
                canShoot = true;

            if(isFiring && !needsReload)
                Fire();

            if(isReloading)
                Reload();
        }

        protected virtual void OnFirePressed() { }
        protected virtual void OnFireReleased() { }

        protected virtual void OnReloadPressed() { }
        protected virtual void OnReloadReleased() { }

        protected virtual void OnScopePressed() { }
        protected virtual void OnScopeReleased() { }

        protected virtual void OnFired() { }
        protected virtual void OnReloaded() { }

        private void Fire()
        {
            if(canShoot)
            {
                OnFired();

                // Reduce ammo by 1, and if we are out of ammo, make needsReload true
                clipAmmo--;
                if (clipAmmo <= 0)
                {
                    needsReload = true;
                }

                // Make the gun wait until it can shoot again
                StartCoroutine(ShootCooldown());

                Vector3 direction = CalculateWeaponSway();
                Debug.DrawRay(shootPos.position, direction);

                // Fire ray for damage detection
                if (Physics.Raycast(shootPos.position, direction, out RaycastHit hit, stats.Range))
                {
                    // Have we hit a player?
                    PlayerNet player = hit.collider.GetComponent<PlayerNet>();
                    if(player != null)
                    {
                        // Damage them and play hit particles at location
                        PacketHandler.SendPacket(new PacketDamagePlayer(player.ID, stats.Damage));
                    }
                    else
                    {

                    }
                }
            }
        }

        private Vector3 CalculateWeaponSway()
        {
            // Modify the amount of weapon sway by a quarter if we are scoping
            float sway = stats.Sway * (isScoping ? 0.25f : 1);

            // Calculate the random offset of the shot
            float vertOffset = Random.Range(-sway, sway);
            float horrOffset = Random.Range(-sway, sway);

            // Run the final calculations of the weapon sway by the random offsets
            return shootPos.forward + (shootPos.right * horrOffset) + (shootPos.up * vertOffset);
        }

        private IEnumerator ShootCooldown()
        {
            canShoot = false;
            isCoolingDown = true;

            // Wait for the time required in between shots
            yield return new WaitForSeconds(stats.FireRate);

            if(stats.IsAutomatic)
            {
                canShoot = true;
            }
            
            isCoolingDown = false;
        }

        private void Reload()
        {
            if(clipAmmo == stats.ClipSize)
                return;

            OnReloaded();

            int requiredReloadAmount = stats.ClipSize - clipAmmo;
            requiredReloadAmount = Mathf.Clamp(requiredReloadAmount, 0, stats.ClipSize);

            // Make sure we have at least an entire clips worth of ammo
            if(totalAmmo - requiredReloadAmount >= 0)
            {
                // Reset our clip ammo to the total minus the clipsize and reduce total ammo by the same amount
                clipAmmo += requiredReloadAmount;
                totalAmmo -= requiredReloadAmount;
            }
            else
            {
                // There is not enough for a full clip, so set the clip ammo to the remaining amount
                clipAmmo += totalAmmo;
                totalAmmo = 0;
            }

            needsReload = false;
        }

        private void OnFirePerformed(InputAction.CallbackContext _context)
        {
            isFiring = true;
            OnFirePressed();
        }

        private void OnFireCanceled(InputAction.CallbackContext _context)
        {
            isFiring = false;
            OnFireReleased();
        }

        private void OnReloadPerformed(InputAction.CallbackContext _context)
        {
            isReloading = true;
            OnReloadPressed();
        }

        private void OnReloadCanceled(InputAction.CallbackContext _context)
        {
            isReloading = false;
            OnReloadReleased();
        }

        private void OnScopePerformed(InputAction.CallbackContext _context)
        {
            isScoping = true;
            OnScopePressed();
        }

        private void OnScopeCanceled(InputAction.CallbackContext _context)
        {
            isScoping = false;
            OnScopeReleased();
        }

        private void OnDrawGizmos()
        {
            if(shootPos == null)
                return;

            Gizmos.color = Color.red;
            Gizmos.DrawWireSphere(shootPos.position, 0.01f);
        }
    }
}