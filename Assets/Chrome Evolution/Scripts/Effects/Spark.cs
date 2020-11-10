using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace ChromeEvo.Effects
{
    [RequireComponent(typeof(ParticleSystem))]
    public class Spark : MonoBehaviour
    {
        [SerializeField]
        private Vector2 timeIntervalRange = new Vector2(0.1f, 5f);
        [SerializeField]
        private new Light light;

        private ParticleSystem particles;

        private float initialIntesity = 0f;

        private float chosenDelay = 0f;
        private float currentTime = 0f;

        private float flashTime = 0.1f;
        private int loops = 0;

        // Start is called before the first frame update
        private void Start()
        {
            particles = gameObject.GetComponent<ParticleSystem>();
            if(light == null)
            {
                light = gameObject.GetComponent<Light>();
            }

            ChooseDelay();
            initialIntesity = light.intensity;
            light.intensity = 0;

            loops = particles.emission.GetBurst(0).cycleCount;
            flashTime = particles.emission.GetBurst(0).repeatInterval;
        }

        // Update is called every frame, if the MonoBehaviour is enabled
        private void Update()
        {
            if(currentTime < chosenDelay)
            {
                currentTime += Time.deltaTime;
            }
            else
            {
                ChooseDelay();
                particles.Play();
                StartCoroutine(LightFlash_CR());
            }
        }

        private void ChooseDelay()
        {
            chosenDelay = Random.Range(timeIntervalRange.x, timeIntervalRange.y);
            currentTime = 0;
        }

        private IEnumerator LightFlash_CR()
        {
            for(int i = 0; i < loops; i++)
            {
                light.intensity = initialIntesity;

                yield return new WaitForSeconds(flashTime);

                light.intensity = 0;

                yield return new WaitForSeconds(flashTime);
            }
        }
    }
}