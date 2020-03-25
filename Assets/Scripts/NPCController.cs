using System.Collections;
using UnityEngine;
using UnityEngine.AI;

public class NPCController : MonoBehaviour
{
    public float patrolTime = 2f;
    public Transform[] waypoints;

    private int index = 0;
    private float speed, agentSpeed, acceleration;

    [SerializeField] private Transform Player;

    private Animator anim;
    public NavMeshAgent agent;
    private GameObject cone;
    private Color idleColor;
    [SerializeField] private ParticleSystem flame1, flame2;
    private Material coneMat;

    //TRIGGERED EVENT
    private bool triggered;
    [SerializeField] private GameObject waypointTriggered;
    [SerializeField] private GameObject crowd;
    private AudioSource gasp;
    private ParticleSystem alert;


    private void Awake()
    {
        anim = GetComponent<Animator>();
        agent = GetComponent<NavMeshAgent>();
        if (agent != null) agentSpeed = agent.speed;
        acceleration = agent.acceleration;
        InvokeRepeating("Tick", 0, 0.5f);

        if (waypoints.Length > 0)
        {
            InvokeRepeating("Patrol", 0, patrolTime);
        }

        cone = gameObject.transform.Find("cone").gameObject;
        coneMat = cone.GetComponent<Renderer>().material;
        idleColor = cone.GetComponent<Renderer>().material.GetColor("_Color0");
        gasp = crowd.transform.Find("Gasp").GetComponent<AudioSource>();
        alert = transform.Find("AlertParticles").GetComponent<ParticleSystem>();
    }

    private void Update()
    {
        if (triggered)
        {
            agent.updateRotation = false;
            Vector3 direction = (Player.position - transform.position).normalized;
            Quaternion lookRotation = Quaternion.LookRotation(direction);
            transform.rotation = Quaternion.Slerp(transform.rotation, lookRotation, Time.deltaTime * 10f);
            if (agent.remainingDistance <= 0.02f)
            {
                DoTrigger(false);
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

    public void DoTrigger(bool isTriggered)
    {
        triggered = isTriggered;
        var mainFlame1 = flame1.main;
        var mainFlame2 = flame2.main;
        if (isTriggered)
        {
            coneMat.SetColor("_Color0", Color.red);
            mainFlame1.startColor = Color.red;
            mainFlame2.startColor = Color.red;
            alert.Play();
            gasp.Play();
            agent.acceleration = acceleration * 2;
            agent.speed = agentSpeed * 2;
            agent.SetDestination(waypointTriggered.transform.position);
        }
        else
        {
            agent.acceleration = acceleration;
            agent.speed = agentSpeed;
            agent.updateRotation = true;
            coneMat.SetColor("_Color0", idleColor);
            mainFlame1.startColor = idleColor;
            mainFlame2.startColor = idleColor;
        }
    }

    void Patrol()
    {
        index = index == waypoints.Length - 1 ? 0 : index + 1;
    }

    void Tick()
    {
        if (triggered)
        {
            agent.SetDestination(waypointTriggered.transform.position);
            CancelInvoke("Tick");
            CancelInvoke("Patrol");
        }
        else
        {
            agent.SetDestination(waypoints[index].position);
        }
    }

    IEnumerator _wait(float waitTime)
    {
        yield return new WaitForSeconds(waitTime);
        agent.isStopped = false;
        InvokeRepeating("Tick", 0, 0.5f);
        InvokeRepeating("Patrol", 0, patrolTime);
    }
}