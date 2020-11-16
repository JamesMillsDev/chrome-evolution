using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace ChromeEvo.Utils
{
    public class RunableUtils
    {
        public static bool Validate<T>(ref T _runable, GameObject _from) where T : IRunable
        {
            if(_runable == null)
            {
                _runable = _from.GetComponent<T>();
                if (_runable != null)
                    return true;
            }

            if(_runable == null)
            {
                _runable = _from.GetComponentInChildren<T>();
                if(_runable != null)
                    return true;
            }

            return false;
        }

        public static bool Setup<T>(ref T _runable, params object[] _params) where T : IRunable
        {
            if(_runable != null)
            {
                _runable.Setup(_params);
                return true;
            }

            return false;
        }

        public static void Run<T>(ref T _runable, params object[] _params) where T : IRunable
        {
            if(_runable != null)
            {
                _runable.Run(_params);
            }
        }
    }
}