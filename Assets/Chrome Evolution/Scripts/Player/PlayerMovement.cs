using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

using ChromeEvo.Utils;

namespace ChromeEvo.Player
{
    #pragma warning disable 0649
    public class PlayerMovement : Runable
    {
        public float SprintVisualFactor { get { return remainingSprintTime / sprintTime; } }
        public bool IsGrounded { get; private set; }
        public Rigidbody Body { get { return rigidbody; } }

        [SerializeField, Range(1, 20)]
        private float jumpForce = 8f;

        [Space]

        [SerializeField, Range(1, 3)]
        private float sprintModifier = 2f;
        [SerializeField, Range(1, 5)]
        private float sprintTime = 2f;

        [Space]

        [SerializeField, Range(1, 20)]
        private float maxSpeedOnGround = 8;
        [SerializeField, Range(1, 20)]
        private float maxSpeedInAir = 8;

        [Space]

        [SerializeField, Min(0.1f)]
        private float groundDistanceCheck = 1f;
        [SerializeField, Min(0.2f)]
        private float groundDistanceInAirCheck = 0.2f;

        [Space]

        [SerializeField, Min(0.1f)]
        private float fallMultiplier = 2.5f;
        [SerializeField, Min(0.2f)]
        private float lowJumpMultiplier = 2f;

        [Space]

        [SerializeField]
        private LayerMask layerChecks;
        [SerializeField, Tag]
        private string groundTag;
        [SerializeField, Tag]
        private string wallTag;

        private PlayerInput input;
        private new Rigidbody rigidbody;
        private new CapsuleCollider collider;
        private Transform playerTransform;
        private new CameraController camera;

        private InputAction moveAction;
        private InputAction jumpAction;
        private InputAction sprintAction;

        private float speedOnGroundModifier = 1;
        private float speedInAirModifier = 1;

        private float lastTimeInAir = 0f;
        private float inAirGroundCheckDelay = 0.2f;

        private bool isJumpPressed = false;

        private float remainingSprintTime = 0;
        private bool canSprint = false;
        private bool sprintCoolingDown = false;
        private bool isSprintPressed = false;

        public override void Setup(params object[] _params)
        {
            // Cache required components
            input = (PlayerInput)_params[0];
            rigidbody = (Rigidbody)_params[1];
            collider = (CapsuleCollider)_params[2];
            playerTransform = (Transform)_params[3];
            camera = (CameraController)_params[4];

            // Cache input actions
            InputUtils.CacheAndEnable(ref input, ref moveAction, "Move");
            InputUtils.CacheAndEnable(ref input, ref jumpAction, "Jump");
            InputUtils.CacheAndEnable(ref input, ref sprintAction, "Sprint");

            // Subscribe actions
            InputUtils.SubscribeEvents(ref jumpAction, OnJumpPerformed, OnJumpCanceled);
            InputUtils.SubscribeEvents(ref sprintAction, OnSprintPerformed, OnSprintCanceled);

            remainingSprintTime = sprintTime;
        }

        public override void Run(params object[] _params)
        {
            CheckGrounded();
            HandleMovement(moveAction.ReadValue<Vector2>());
            ApplyExtraGravity();
            UpdateSprintTimer();
        }

        private void CheckGrounded()
        {
            float chosenGroundCheckDistance = IsGrounded ? groundDistanceCheck : groundDistanceInAirCheck;

            if(Time.time >= lastTimeInAir + inAirGroundCheckDelay)
            {
                RaycastHit[] hits = CapsuleCastAllInDirection(-playerTransform.up, chosenGroundCheckDistance);

                if(hits.Length > 0)
                {
                    foreach(RaycastHit hit in hits)
                    {
                        if(hit.collider.CompareTag(groundTag) || hit.collider.gameObject.layer == 0)
                        {
                            IsGrounded = true;
                            return;
                        }
                        else
                        {
                            IsGrounded = false;
                        }
                    }
                }
                else
                {
                    IsGrounded = false;
                }
            }
        }

        private void HandleMovement(Vector2 _axis)
        {
            if(!camera.Enabled)
                return;

            float maxSpeed = IsGrounded ? maxSpeedOnGround : maxSpeedInAir;
            float modifier = (IsGrounded ? speedOnGroundModifier : speedInAirModifier) * (isSprintPressed && canSprint ? sprintModifier : 1f);

            Vector3 forward = playerTransform.forward * _axis.y;
            Vector3 right = playerTransform.right * _axis.x;
            Vector3 desiredVelocity = ((forward + right) * maxSpeed * modifier) - rigidbody.velocity;

            if(CanMoveInDirection(desiredVelocity))
            {
                rigidbody.AddForce(new Vector3(desiredVelocity.x, 0, desiredVelocity.z), ForceMode.Impulse);
            }
        }

        private void ApplyExtraGravity()
        {
            if(rigidbody.velocity.y < 0)
            {
                rigidbody.velocity += Vector3.up * Physics.gravity.y * (fallMultiplier - 1) * Time.deltaTime;
            }
            else if(rigidbody.velocity.y > 0 && !isJumpPressed)
            {
                rigidbody.velocity += Vector3.up * Physics.gravity.y * (lowJumpMultiplier - 1) * Time.deltaTime;
            }
        }

        private void UpdateSprintTimer()
        {
            if(isSprintPressed && canSprint)
            {
                remainingSprintTime -= Time.deltaTime;

                if(remainingSprintTime <= 0f)
                {
                    sprintCoolingDown = true;
                    canSprint = false;
                }
            }
            else if(!isSprintPressed)
            {
                remainingSprintTime += Time.deltaTime;
            }

            if(sprintCoolingDown)
            {
                remainingSprintTime += Time.deltaTime;
                if(remainingSprintTime < sprintTime * 0.1f)
                {
                    canSprint = false;
                }
                else if(remainingSprintTime > sprintTime * 0.1f)
                {
                    canSprint = true;
                    sprintCoolingDown = false;
                }
            }
            else
            {
                canSprint = true;
            }

            remainingSprintTime = Mathf.Clamp(remainingSprintTime, 0, sprintTime);
        }

        private bool CanMoveInDirection(Vector3 _targetDir)
        {
            RaycastHit[] hits = CapsuleCastAllInDirection(_targetDir, 0.5f);

            foreach(RaycastHit hit in hits)
            {
                if(hit.collider.CompareTag(wallTag) || hit.collider.gameObject.layer == 0)
                {
                    return false;
                }
            }

            return true;
        }

        private RaycastHit[] CapsuleCastAllInDirection(Vector3 _dir, float _distance)
        {
            Vector3 top = playerTransform.position + collider.center + Vector3.up * ((collider.height * 0.5f) - collider.radius);
            Vector3 bot = playerTransform.position + collider.center - Vector3.up * ((collider.height * 0.5f) - collider.radius);

            return Physics.CapsuleCastAll(top, bot, collider.radius * 0.9f, _dir, _distance, layerChecks);
        }

        private void OnJumpPerformed(InputAction.CallbackContext _context)
        {
            if (!camera.Enabled)
                return;

            isJumpPressed = true;
            
            if(IsGrounded)
            {
                rigidbody.AddForce(Vector3.up * jumpForce, ForceMode.Impulse);
                IsGrounded = false;

                lastTimeInAir = Time.time;
            }
        }

        private void OnJumpCanceled(InputAction.CallbackContext _context)
        {
            isJumpPressed = false;
        }

        private void OnSprintPerformed(InputAction.CallbackContext _context)
        {
            isSprintPressed = true;
        }

        private void OnSprintCanceled(InputAction.CallbackContext _context)
        {
            isSprintPressed = false;
        }
    }
}