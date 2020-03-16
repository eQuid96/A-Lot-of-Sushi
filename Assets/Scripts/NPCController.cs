using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class NPCController : MonoBehaviour
{
    public float patrolTime = 2f;
    public Transform[] waypoints;

    private int index = 0;
    private float speed, agentSpeed, acceleration;
    
    [SerializeField]
    private Transform Player;

    private Animator anim;
    public NavMeshAgent agent;
    private GameObject cone;
    private Color originalConeColor;
    public GameObject flame1, flame2;

    //TRIGGERED EVENT
    private bool _triggered;
    public bool Triggered {
        get {
            return _triggered;
        }
        set {
            _triggered = value;
            if (value) {
                cone.GetComponent<Renderer>().material.SetColor("_Color0", Color.red);
                flame1.GetComponent<Renderer>().material.SetColor("_Color0", Color.red);
                flame2.GetComponent<Renderer>().material.SetColor("_Color0", Color.red);
                alert.Play();
                gasp.Play();
                agent.acceleration = 100f;
                agent.speed = 100f;
                agent.updateRotation = false;
            } else {
                agent.acceleration = acceleration;
                agent.speed = agentSpeed;
                agent.updateRotation = true;
                cone.GetComponent<Renderer>().material.SetColor("_Color0", originalConeColor);
                flame1.GetComponent<Renderer>().material.SetColor("_Color0", originalConeColor);
                flame2.GetComponent<Renderer>().material.SetColor("_Color0", originalConeColor);
            }
        }
    }
    [SerializeField]
    private GameObject waypointTriggered;
    [SerializeField]
    private GameObject crowd;
    private AudioSource gasp;
    private ParticleSystem alert;
    

    private void Awake() {
        anim = GetComponent<Animator>();
        agent = GetComponent<NavMeshAgent>();
        if (agent != null) agentSpeed = agent.speed;
        acceleration = agent.acceleration;
        // player = GameObject.FindGameObjectWithTag("Player").transform;
        InvokeRepeating("Tick", 0, 0.5f);

        if (waypoints.Length > 0) {
            InvokeRepeating("Patrol", 0, patrolTime);
        }

        cone = gameObject.transform.Find("cone").gameObject;
        originalConeColor = cone.GetComponent<Renderer>().material.GetColor("_Color0");

        gasp = crowd.transform.Find("Gasp").GetComponent<AudioSource>();
        alert = transform.Find("AlertParticles").GetComponent<ParticleSystem>();
    }

    void FixedUpdate()
    {
        if (Triggered) {
            agent.SetDestination(waypointTriggered.transform.position);
            Vector3 direction = (Player.position - transform.position).normalized;
            Quaternion lookRotation = Quaternion.LookRotation(direction);
            transform.rotation = Quaternion.Slerp(transform.rotation, lookRotation, Time.deltaTime * 10f);
            if (agent.remainingDistance <= 0.02f) {
                Triggered = false;
                agent.isStopped = true;
                StartCoroutine(_wait(5));
            }
        }
        if (agent.remainingDistance <= 0.2f)
        {
            anim.SetBool("isMoving", false);
        }
        else
        {
            anim.SetBool("isMoving", true);
        }
    }

    void Patrol() {
        index = index == waypoints.Length-1 ? 0 : index + 1;
    }

    void Tick() {
        if (Triggered) {
            Debug.Log("here");
            agent.SetDestination(waypointTriggered.transform.position);
            CancelInvoke("Tick");
            CancelInvoke("Patrol");
        } else {
            agent.SetDestination(waypoints[index].position);
        }
    }

    IEnumerator _wait(float waitTime)
    {
        yield return new WaitForSeconds(waitTime);
        Debug.Log("restarting patrol");
        agent.isStopped = false;
        InvokeRepeating("Tick", 0, 0.5f);
        InvokeRepeating("Patrol", 0, patrolTime);
    }
}
