using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

using ChromeEvo.Utils;

namespace ChromeEvo.Player
{
    [RequireComponent(typeof(Animator))]
    public class PlayerRendering : Runable
    {
        [SerializeField]
        private Material localPlayerMat;
        [SerializeField]
        private List<Renderer> localObjects = new List<Renderer>();

        private Animator animator;

        private PlayerInput input;
        private InputAction moveAction;

        public override void Setup(params object[] _params)
        {
            // Cache components
            input = (PlayerInput)_params[0];
            animator = gameObject.GetComponent<Animator>();

            // Cache input actions
            InputUtils.CacheAndEnable(ref input, ref moveAction, "Move");

            // Change all local objects to the correct layer
            foreach(Renderer rend in localObjects)
            {
                rend.material = localPlayerMat;
            }
        }

        public override void Run(params object[] _params)
        {
            Vector2 axis = moveAction.ReadValue<Vector2>();

            animator.SetFloat("Speed", Mathf.Clamp(axis.y, -0.5f, 1f));
        }
    }
}