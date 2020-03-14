using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BackgroundMusicLoop : MonoBehaviour
{
    public AudioSource myAudio;
    [Range(0f, 26.5f)] // loops at 14.45-23.17
    public float loopStart, loopEnd;
 
    private void Awake() {
        DontDestroyOnLoad(gameObject);    
    }

    void Start(){
        myAudio.Play();
    }
 

    void Update(){
        // TODO: put here
        if (myAudio.isPlaying && myAudio.time > loopEnd) {
            myAudio.time = loopStart;
        }
    }
}
