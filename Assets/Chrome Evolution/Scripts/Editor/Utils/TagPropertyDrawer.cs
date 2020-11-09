using UnityEngine;
using UnityEditor;

namespace ChromeEvo.Utils
{
    [CustomPropertyDrawer(typeof(TagAttribute))]
    public class TagPropertyDrawer : PropertyDrawer
    {
        public override void OnGUI(Rect _position, SerializedProperty _property, GUIContent _label)
        {
            EditorGUI.BeginProperty(_position, _label, _property);

            bool isNotSet = false;
            if (string.IsNullOrEmpty(_property.stringValue))
                isNotSet = true;

            _property.stringValue = EditorGUI.TagField(_position, _label, isNotSet ? (_property.serializedObject.targetObject as Component).gameObject.tag : _property.stringValue);

            EditorGUI.EndProperty();
        }

        public override float GetPropertyHeight(SerializedProperty _property, GUIContent _label)
        {
            return EditorGUIUtility.singleLineHeight;
        }
    }
}