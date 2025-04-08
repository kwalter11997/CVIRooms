using System.Collections.Generic;
using UnityEngine;

public class LeftEyePos : MonoBehaviour
{
    [SerializeField]
    private float rayDistance = 10.0f;

    private LineRenderer lineRenderer;

    [SerializeField]
    private LayerMask allLayers;

    [SerializeField]
    public GameObject eye;

    public static Vector3 eyePos;
    public static Vector3 eyeRot;

    // Start is called before the first frame update
    void Start()
    {
        lineRenderer = GetComponent<LineRenderer>();
    }

    // Update is called once per frame
    void Update()
    {
        RaycastHit hit;

        Vector3 rayCastDirection = transform.TransformDirection(Vector3.forward) * rayDistance;

        if (Physics.Raycast(transform.position, rayCastDirection, out hit, Mathf.Infinity, allLayers))
        {
            eyePos = hit.point;
            eyeRot = eye.transform.rotation.eulerAngles;
            //Debug.Log(hit.point);
        }
    }
}
