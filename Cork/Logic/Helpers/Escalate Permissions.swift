//
//  Escalate Privileges.swift
//  Cork
//
//  Created by David Bureš on 05.10.2023.
//

import Foundation

//
//  Escalate Permissions.swift
//  Cork
//
//  Created by David Bureš on 29.09.2023.
//

import Foundation
import ServiceManagement

enum PermissionsEscalationError: Error
{
    case couldNotObtainPermissions
}

func escalatePermissions() async throws -> OSStatus
{
    var authorizationReference: AuthorizationRef?
    var authorizationItem: AuthorizationItem = AuthorizationItem(name: kSMRightBlessPrivilegedHelper, valueLength: 0, value: nil, flags: 0)
    var authorizationRights = AuthorizationRights(count: 1, items: &authorizationItem)

    let flags: AuthorizationFlags = [.interactionAllowed, .preAuthorize, .extendRights]

    var environment: AuthorizationEnvironment = AuthorizationEnvironment()

    var authorizationStatus = AuthorizationCreate(&authorizationRights, &environment, flags, &authorizationReference)

    guard let authRef = authorizationReference else
    {
        print("Failed to get authorization")
        throw PermissionsEscalationError.couldNotObtainPermissions
    }

    authorizationStatus = AuthorizationCopyRights(authRef, &authorizationRights, &environment, flags, nil)

    print("Authorization status: \(authorizationStatus) - \(String(authStatus: authorizationStatus))")

    return authorizationStatus
}

extension String {
    init(authStatus: OSStatus) {

        switch authStatus {
            case errAuthorizationSuccess:
                self = "Success"

            case errAuthorizationDenied:
                self = "Denied"

            case errAuthorizationCanceled:
                self = "Cancelled"

            case errAuthorizationInternal:
                self = "Internal error"

            case errAuthorizationBadAddress:
                self = "Bad address"

            case errAuthorizationInvalidRef:
                self = "Invalid reference"

            case errAuthorizationInvalidSet:
                self = "Invalid set"

            case errAuthorizationInvalidTag:
                self = "Invalid tag"

            case errAuthorizationInvalidFlags:
                self = "Invalid flags"

            case errAuthorizationInvalidPointer:
                self = "Invalid pointer"

            case errAuthorizationToolExecuteFailure:
                self = "Tool execution failure"

            case errAuthorizationToolEnvironmentError:
                self = "Tool environment error"

            case errAuthorizationExternalizeNotAllowed:
                self = "Reference externalization not allowed"

            case errAuthorizationInteractionNotAllowed:
                self = "Interaction not allowed"

            case errAuthorizationInternalizeNotAllowed:
                self = "Reference internalization not allowed"

            default:
                self = "Unknown auth failure"
        }
    }
}
