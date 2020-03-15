using UnityEngine;
[RequireComponent(typeof(Rigidbody))]
public class ThrowableObject : MonoBehaviour
{
    private const float FORCE_MULTIPLIER = 100.0f;
    private Rigidbody rb;
    private bool isThrowing;
    private float throwForce;
    void Start()
    {
        rb = GetComponent<Rigidbody>();
        rb.isKinematic = true;
    }

    private void FixedUpdate()
    {
        if (isThrowing)
        {
            rb.AddForce(transform.forward * throwForce * Time.fixedDeltaTime, ForceMode.Impulse);
        }
    }

    public void Throw(float _throwForce)
    {
        rb.transform.parent = null;
        rb.isKinematic = false;
        isThrowing = true;
        throwForce = _throwForce * FORCE_MULTIPLIER;
    }

    private void OnCollisionEnter(Collision collision)
    {
        isThrowing = false;
    }
}
