using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using UnityEngine;

public class EyeTrackingRay : MonoBehaviour
{
    [SerializeField]
    private float rayDistance = 10.0f;

    [SerializeField]
    private float rayWidth = 0.01f;

    [SerializeField]
    private Color rayColorDefaultState = Color.clear;
    [SerializeField]
    private Color rayColorHoverState = Color.clear;

    [SerializeField]
    private LayerMask layersToInclude;

    [SerializeField]
    private LayerMask backgroundLayers;

    private LineRenderer lineRenderer;

    private List<EyeInteractable> eyeInteractables = new List<EyeInteractable>();

    //public static bool targetHit;
    public static string objectname;

    // Start is called before the first frame update
    void Start()
    {
        lineRenderer = GetComponent<LineRenderer>();
        SetupRay();
    }

    void SetupRay()
    {
        lineRenderer.startWidth = rayWidth;
        lineRenderer.endWidth = rayWidth;

        lineRenderer.startColor = rayColorDefaultState;
        lineRenderer.endColor = rayColorDefaultState;
    }

    // Update is called once per frame
    void Update()
    {
        RaycastHit hit;

        Vector3 rayCastDirection = transform.TransformDirection(Vector3.forward) * rayDistance;

        if (Physics.Raycast(transform.position, rayCastDirection, out hit, Mathf.Infinity, layersToInclude))
        {
            Unselect();
            var eyeInteractable = hit.transform.GetComponent<EyeInteractable>();
            eyeInteractables.Add(eyeInteractable);
            eyeInteractable.IsHovered = true;
            objectname = hit.collider.gameObject.name;
            //targetHit = true;
        }
        else
        {
            Unselect(true);
            //targetHit = false;
            objectname = "Wall";
        }
    }

    void Unselect(bool clear = false)
    {
        foreach (var interactable in eyeInteractables)
        {
            interactable.IsHovered = false;
        }
        if(clear)
        {
            eyeInteractables.Clear();
        }
    }
}
