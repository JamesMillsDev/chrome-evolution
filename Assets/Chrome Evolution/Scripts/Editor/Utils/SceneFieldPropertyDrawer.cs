using UnityEngine;
using UnityEditor;

namespace ChromeEvo.Utils
{
    [CustomPropertyDrawer(typeof(SceneField))]
    public class SceneFieldPropertyDrawer : PropertyDrawer
    {
        public override void OnGUI(Rect _position, SerializedProperty _property, GUIContent _label)
        {
            var oldPath = AssetDatabase.LoadAssetAtPath<SceneAsset>(_property.stringValue);

            _position = EditorGUI.PrefixLabel(_position, new GUIContent(_property.displayName));

            EditorGUI.BeginChangeCheck();
            var newScene = EditorGUI.ObjectField(_position, oldPath, typeof(SceneAsset), false) as SceneAsset;

            if(EditorGUI.EndChangeCheck())
            {
                var newPath = AssetDatabase.GetAssetPath(newScene);
                _property.stringValue = newPath;
            }
        }
    }
}