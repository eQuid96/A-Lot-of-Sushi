using UnityEngine;
[RequireComponent(typeof(Rigidbody))]
public class ThrowableObject : MonoBehaviour
{
    private Rigidbody rb;
    private float throwForce;
    void Start()
    {
        rb = GetComponent<Rigidbody>();
        rb.isKinematic = true;
    }

    public void Throw(float _throwForce)
    {
        rb.transform.parent = null;
        rb.isKinematic = false;
        throwForce = _throwForce;
        rb.AddForce(Camera.main.transform.forward * throwForce, ForceMode.Impulse);
    }

    private void OnCollisionEnter(Collision collision)
    {
        Debug.Log(collision.collider.name);
        Destroy(gameObject, 2.0f);
    }
}
