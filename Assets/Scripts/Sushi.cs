using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Sushi : MonoBehaviour
{
    public Vector3 startPosition;
    public bool detectable;
    public UIElements ui;
    public NPCController npc;
    [SerializeField]
    private AudioSource dishSound;

    // Start is called before the first frame update
    void Start()
    {
        startPosition.y = startPosition.y + gameObject.transform.localScale.y;
    }

    private void OnCollisionEnter(Collision collision) {
        if(collision.gameObject.name == "Waiter"){
            Detected();
        }else if (collision.gameObject.name == "Dish"){
            dishSound.Play();
        }
    }
    
    private void OnTriggerEnter(Collider triggered) {
        Debug.Log(triggered.gameObject.name);
        if (triggered.gameObject.name == "cone"){
            Detected();
        }
    }

    private void Detected(){
        gameObject.transform.position = startPosition;
        // ui.Detected();  
        npc.Triggered = true;
    }
}
