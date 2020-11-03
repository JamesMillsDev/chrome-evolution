using System;

using UnityEngine;
using UnityEngine.InputSystem;

namespace ChromeEvo.Utils
{
    public class InputUtils
    {
        public static void CacheAndEnable(ref PlayerInput _input, ref InputAction _action, string _name)
        {
            _action = _input.actions.FindAction(_name);
            _action.Enable();
        }

        public static void SubscribeEvents(ref InputAction _action, Action<InputAction.CallbackContext> _performed, Action<InputAction.CallbackContext> _canceled)
        {
            if(_performed != null)
            {
                _action.performed += _performed;
            }

            if(_canceled != null)
            {
                _action.canceled += _canceled;
            }
        }
    }
}