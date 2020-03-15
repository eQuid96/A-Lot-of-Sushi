using UnityEngine;
[RequireComponent(typeof(Rigidbody))]
public class ThrowableObject : MonoBehaviour
{
    private Rigidbody rb;
    private float throwForce;
    public bool isThrowing;
    private bool hasCollide;
    private float timer = 0.0f;
    private const float MIN_TIME_ON_COLLISION = 0.5f;

    [Header("Score Info:")]
    public int tableScore = 100;
    void Start()
    {
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
        Destroy(gameObject, 2.0f);
        timer += Time.deltaTime;
        if (!hasCollide && timer >= MIN_TIME_ON_COLLISION)
        {
            if (collision.transform.CompareTag("Table"))
            {
                hasCollide = true;
                PlayerManager.instance.AddScore(tableScore);
                return;
            }
        }
    }
}
