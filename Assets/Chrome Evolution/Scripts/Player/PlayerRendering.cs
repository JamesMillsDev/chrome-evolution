using System.Collections.Generic;

using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.InputSystem;

using ChromeEvo.Utils;

using Mirror;

namespace ChromeEvo.Player
{
    public class PlayerRendering : Runable
    {
        [SerializeField]
        private List<Renderer> localObjects = new List<Renderer>();
        [SerializeField]
        private Animator animator;
        [SerializeField]
        private NetworkAnimator netAnimator;

        private PlayerInput input;
        private InputAction moveAction;

        public override void Setup(params object[] _params)
        {
            // Cache components
            input = (PlayerInput)_params[0];
            if(animator == null)
                animator = gameObject.GetComponent<Animator>();

            // Cache input actions
            InputUtils.CacheAndEnable(ref input, ref moveAction, "Move");

            // Change all local objects to the correct layer
            foreach(Renderer rend in localObjects)
            {
                rend.shadowCastingMode = ShadowCastingMode.ShadowsOnly;
            }
        }

        public override void Run(params object[] _params)
        {
            Vector2 axis = moveAction.ReadValue<Vector2>();

            animator.SetFloat("Speed", Mathf.Clamp(axis.y, -0.5f, 1f));
        }
    }
}