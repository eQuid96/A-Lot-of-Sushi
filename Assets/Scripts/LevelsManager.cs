using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LevelsManager : MonoBehaviour
{

    private GameObject[] clients; 
    private int lvl = 1; 

    void Start()
    {
        clients = GameObject.FindGameObjectsWithTag("Client");
        foreach (var item in clients)
        {
            item.GetComponent<Renderer>().enabled = false;
        }
        SpawnStuff();
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void SpawnStuff(){
        int index=0;
        switch(lvl) {
            case 1:
                for(int i=0; i < 22; i++) {
                    clients[i].GetComponent<Renderer>().enabled = true;
                }
                break;
            case 2:
                while(index < 16) {
                    
                }
                break;   
            case 3:
                for(int i=0; i < 13; i++) {
                    clients[i].SetActive(true);
                }
                break;  
            case 4:
                for(int i=0; i < 10; i++) {
                    clients[i].SetActive(true);
                }
                break;   
            case 5:
                for(int i=0; i < 5; i++) {
                    clients[i].SetActive(true);
                }
                break;     
        }
    }
}
