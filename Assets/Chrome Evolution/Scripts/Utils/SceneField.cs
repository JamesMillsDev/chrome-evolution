using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace ChromeEvo.Utils
{
    public class SceneField : PropertyAttribute
    {
        public static string LoadableName(string _path)
        {
            string start = "Assets/";
            string end = ".unity";

            if(_path.EndsWith(end))
            {
                _path = _path.Substring(0, _path.LastIndexOf(end));
            }

            if(start.StartsWith(start))
            {
                _path = _path.Substring(start.Length);
            }

            return _path;
        }
    }
}