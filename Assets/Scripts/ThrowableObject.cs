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
    private AudioSource dishSound;

    void Awake() {
        NPC = GameObject.Find("Waitress").GetComponent<NPCController>();
        dishSound = GameObject.Find("DishSound").GetComponent<AudioSource>();
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
    
    private void OnTriggerEnter(Collider triggered) {
        if (triggered.transform.CompareTag("Cone")){
            Detected();
        }
    }

    private void Detected(){
        Vector3 augmented = startPosition;
        augmented.y = augmented.y + 2f;
        gameObject.transform.position = augmented;
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
