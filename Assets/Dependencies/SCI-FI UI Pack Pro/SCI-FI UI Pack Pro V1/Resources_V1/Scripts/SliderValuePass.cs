using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

using TMPro;

public class SliderValuePass : MonoBehaviour
{
	private TextMeshProUGUI progress;

	// Use this for initialization
	void Start()
    {
		progress = GetComponent<TextMeshProUGUI>();
	}
	
	public void UpdateProgress(float _content)
    {
        if(progress != null)
        {
            progress.text = Mathf.Round(_content * 100) + "%";
        }
	}
}
