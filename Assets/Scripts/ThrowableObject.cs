using UnityEngine;
[RequireComponent(typeof(Rigidbody))]
public class ThrowableObject : MonoBehaviour
{
    private Rigidbody rb;
    private float throwForce;
    public bool isThrowing;
    private bool hasCollide;
    private float timer = 0.0f;
    private const float MIN_TIME_ON_COLLISION = 0.3f;
    private Vector3 startPosition;
    private Quaternion startRotation;
    private Transform startParent;

    [Header("Score Info:")]
    public int tableScore = 100;
    public int ciotolaScore = 300;
    public int tagliereScore = 200;

    private NPCController NPC;
    private GameObject sounds;
    private AudioSource dishSound, whoosh;

    void Awake() {
        sounds = GameObject.Find("[Sounds Source]");
        NPC = GameObject.Find("Waitress").GetComponent<NPCController>();
        dishSound = sounds.transform.Find("DishSound").GetComponent<AudioSource>();
        whoosh = sounds.transform.Find("Whoosh").GetComponent<AudioSource>();
    }

    void Start()
    {
        startParent = transform.parent;
        startPosition = transform.localPosition;
        startRotation = transform.localRotation;
        rb = GetComponent<Rigidbody>();
        rb.isKinematic = true;
    }

    public void Throw(float _throwForce)
    {
        isThrowing = true;
        rb.transform.parent = null;
        rb.isKinematic = false;
        throwForce = _throwForce;
        rb.AddForce(Camera.main.transform.forward * throwForce, ForceMode.Impulse);
        whoosh.Play();
    }
    private void OnCollisionStay(Collision collision)
    {
        isThrowing = false;
        
        Debug.Log(collision.transform.name);
        Invoke("ResetPosition", 2.0f);
        timer += Time.deltaTime;
        if (!hasCollide && timer >= MIN_TIME_ON_COLLISION)
        {
            if (collision.transform.CompareTag("Table"))
            {
                hasCollide = true;
                PlayerManager.instance.AddScore(tableScore);
                return;
            }
            if (collision.transform.CompareTag("Ciotola"))
            {
                hasCollide = true;
                PlayerManager.instance.AddScore(ciotolaScore);
                return;
            }
            if (collision.transform.CompareTag("Tagliere"))
            {
                hasCollide = true;
                PlayerManager.instance.AddScore(tagliereScore);
                return;
            }
        }
    }

    private void OnCollisionEnter(Collision collision) {
        if(collision.transform.CompareTag("Waiter")){
            Detected();
        }else if (collision.transform.CompareTag("Tagliere")){
            dishSound.Play();
        }
    }
    
    private void OnTriggerEnter(Collider triggered) 
    {
        if (isThrowing && triggered.transform.CompareTag("Cone"))
        {
            Detected();
        }
    }

    private void Detected(){
        ResetPosition();
        PlayerManager.instance.RemoveLife();
        NPC.Triggered = true;
    }

    private void ResetPosition()
    {
        timer = 0;
        hasCollide = false;
        isThrowing = false;
        rb.isKinematic = true;
        transform.parent = startParent;
        transform.localPosition = startPosition;
        transform.localRotation = startRotation;
    }
}
